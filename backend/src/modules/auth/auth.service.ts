import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import {
  AuthTokenPurpose,
  LanguageCode,
  MeasurementUnit,
  Prisma,
  ShopRole,
  ShopStatus,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes, randomInt } from 'crypto';
import { PrismaService } from '../../common/prisma/prisma.service';
import {
  ChangePasswordDto,
  CompleteOnboardingDto,
  ForgotIdentifierDto,
  ForgotPasswordDto,
  LoginDto,
  OnboardingDraftDto,
  RegisterDto,
  ResetPasswordDto,
  UpdateProfileDto,
  VerifyOtpDto,
} from './dto/auth.dto';
import { JwtPayload } from './auth.types';
import { normalizePhone, resolveIdentifier } from './phone.util';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }

  private isDevExpose() {
    return (
      this.config.get('NODE_ENV') !== 'production' &&
      this.config.get('AUTH_DEV_EXPOSE_CODES') === 'true'
    );
  }

  private requireVerification() {
    return this.config.get('AUTH_REQUIRE_VERIFICATION') === 'true';
  }

  private async buildPayload(userId: string): Promise<JwtPayload> {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      include: {
        platformAdmin: true,
        memberships: {
          where: { isActive: true },
          include: { shop: { select: { id: true, status: true } } },
        },
      },
    });

    return {
      sub: user.id,
      email: user.email,
      isPlatformAdmin: Boolean(user.platformAdmin),
      memberships: user.memberships.map((m) => ({
        shopId: m.shopId,
        role: m.role,
        status: m.shop.status,
      })),
    };
  }

  private async issueTokens(userId: string) {
    const payload = await this.buildPayload(userId);
    const accessToken = await this.jwt.signAsync(payload, {
      secret: this.config.getOrThrow('JWT_ACCESS_SECRET'),
      expiresIn: this.config.get('JWT_ACCESS_EXPIRES', '30d'),
    });

    const refreshToken = randomBytes(48).toString('hex');
    const refreshExpires = this.config.get('JWT_REFRESH_EXPIRES', '30d');
    const days = refreshExpires.endsWith('d')
      ? parseInt(refreshExpires, 10)
      : 30;
    const expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash: this.hashToken(refreshToken),
        expiresAt,
      },
    });

    return { accessToken, refreshToken, expiresAt, payload };
  }

  async register(dto: RegisterDto) {
    if (!dto.email && !dto.phone) {
      throw new BadRequestException({
        code: 'IDENTIFIER_REQUIRED',
        message: 'Email or mobile number is required',
      });
    }
    if (dto.password.length < 8) {
      throw new BadRequestException({
        code: 'WEAK_PASSWORD',
        message: 'Password must be at least 8 characters',
      });
    }

    const email = dto.email?.trim().toLowerCase() || null;
    const phone = dto.phone ? normalizePhone(dto.phone) : null;
    if (dto.phone && !phone) {
      throw new BadRequestException({
        code: 'INVALID_PHONE',
        message: 'Invalid mobile number',
      });
    }

    if (email) {
      const exists = await this.prisma.user.findUnique({ where: { email } });
      if (exists) {
        throw new ConflictException({
          code: 'IDENTIFIER_IN_USE',
          message: 'Unable to create account with the provided credentials',
        });
      }
    }
    if (phone) {
      const exists = await this.prisma.user.findUnique({ where: { phone } });
      if (exists) {
        throw new ConflictException({
          code: 'IDENTIFIER_IN_USE',
          message: 'Unable to create account with the provided credentials',
        });
      }
    }

    const autoVerify = !this.requireVerification();
    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = await this.prisma.user.create({
      data: {
        email,
        phone,
        altPhone: dto.altPhone ? normalizePhone(dto.altPhone) : undefined,
        passwordHash,
        fullName: dto.fullName,
        languagePref: dto.languagePref ?? LanguageCode.gu,
        emailVerifiedAt: email && autoVerify ? new Date() : null,
        phoneVerifiedAt: phone && autoVerify ? new Date() : null,
        onboardingStep: 1,
      },
    });

    const tokens = await this.issueTokens(user.id);
    return this.toAuthResponse(user.id, tokens);
  }

  async login(dto: LoginDto) {
    const generic = {
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email/mobile number or password',
    };
    const resolved = resolveIdentifier(dto.identifier);
    if (!resolved) throw new UnauthorizedException(generic);

    const user =
      resolved.type === 'email'
        ? await this.prisma.user.findUnique({
            where: { email: resolved.value },
          })
        : await this.prisma.user.findUnique({
            where: { phone: resolved.value },
          });

    if (!user || !user.isActive) {
      throw new UnauthorizedException(generic);
    }
    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) throw new UnauthorizedException(generic);

    if (this.requireVerification()) {
      const needEmail = user.email && !user.emailVerifiedAt;
      const needPhone = user.phone && !user.phoneVerifiedAt && !user.email;
      if (needEmail || needPhone) {
        const tokens = await this.issueTokens(user.id);
        const profile = await this.me(user.id);
        return {
          ...this.wrapAuth(profile, tokens),
          requiresVerification: true,
          verificationChannel: needEmail ? 'email' : 'phone',
        };
      }
    }

    const tokens = await this.issueTokens(user.id);
    return this.toAuthResponse(user.id, tokens);
  }

  /** Accept legacy { email, password } from web */
  async loginFlexible(body: {
    identifier?: string;
    email?: string;
    password: string;
  }) {
    const identifier = body.identifier || body.email;
    if (!identifier) {
      throw new BadRequestException({
        code: 'IDENTIFIER_REQUIRED',
        message: 'Email or mobile number is required',
      });
    }
    return this.login({ identifier, password: body.password });
  }

  async refresh(refreshToken: string) {
    const hash = this.hashToken(refreshToken);
    const stored = await this.prisma.refreshToken.findFirst({
      where: { tokenHash: hash, revokedAt: null },
    });
    if (!stored || stored.expiresAt < new Date()) {
      throw new UnauthorizedException({
        code: 'INVALID_REFRESH',
        message: 'Refresh token is invalid or expired',
      });
    }
    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    const tokens = await this.issueTokens(stored.userId);
    return this.toAuthResponse(stored.userId, tokens);
  }

  async logout(refreshToken?: string, userId?: string) {
    if (refreshToken) {
      const hash = this.hashToken(refreshToken);
      await this.prisma.refreshToken.updateMany({
        where: { tokenHash: hash, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    } else if (userId) {
      await this.prisma.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
    return { success: true };
  }

  async me(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        altPhone: true,
        fullName: true,
        avatarUrl: true,
        languagePref: true,
        themePref: true,
        isActive: true,
        emailVerifiedAt: true,
        phoneVerifiedAt: true,
        onboardingStep: true,
        onboardingDraft: true,
        onboardingCompletedAt: true,
        platformAdmin: { select: { id: true, isSuperAdmin: true } },
        memberships: {
          where: { isActive: true },
          select: {
            id: true,
            role: true,
            shop: {
              select: {
                id: true,
                name: true,
                slug: true,
                status: true,
                defaultLanguage: true,
                measurementUnit: true,
                onboardingCompletedAt: true,
              },
            },
          },
        },
      },
    });
    const onboardingComplete = Boolean(
      user.onboardingCompletedAt ||
        user.memberships.some((m) => m.shop.onboardingCompletedAt || m.role),
    );
    // Prefer membership presence as completion for existing shops
    const hasShop = user.memberships.length > 0;
    return {
      ...user,
      isPlatformAdmin: Boolean(user.platformAdmin),
      onboardingComplete: hasShop || onboardingComplete,
      requiresVerification: this.requireVerification()
        ? Boolean(
            (user.email && !user.emailVerifiedAt) ||
              (!user.email && user.phone && !user.phoneVerifiedAt),
          )
        : false,
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const data: Prisma.UserUpdateInput = { ...dto };
    if (dto.phone) {
      const phone = normalizePhone(dto.phone);
      if (!phone) {
        throw new BadRequestException({
          code: 'INVALID_PHONE',
          message: 'Invalid mobile number',
        });
      }
      data.phone = phone;
    }
    return this.prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        email: true,
        fullName: true,
        phone: true,
        altPhone: true,
        languagePref: true,
        themePref: true,
        avatarUrl: true,
      },
    });
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    const ok = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!ok) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Current password is incorrect',
      });
    }
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: await bcrypt.hash(dto.newPassword, 12) },
    });
    await this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { success: true };
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const generic = {
      success: true,
      message:
        'If an account exists for that identifier, recovery instructions were sent.',
      channel: null as string | null,
    };
    const resolved = resolveIdentifier(dto.identifier);
    if (!resolved) return generic;

    const user =
      resolved.type === 'email'
        ? await this.prisma.user.findUnique({
            where: { email: resolved.value },
          })
        : await this.prisma.user.findUnique({
            where: { phone: resolved.value },
          });

    if (!user) return generic;

    const raw =
      resolved.type === 'phone'
        ? String(randomInt(100000, 999999))
        : randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000);
    await this.prisma.authToken.create({
      data: {
        userId: user.id,
        purpose: AuthTokenPurpose.PASSWORD_RESET,
        tokenHash: this.hashToken(raw),
        expiresAt,
        meta: { channel: resolved.type },
      },
    });

    // Provider hooks — not configured in local/dev by default
    const emailConfigured = Boolean(this.config.get('SMTP_URL'));
    const smsConfigured = Boolean(this.config.get('SMS_PROVIDER_API_KEY'));
    if (resolved.type === 'email' && emailConfigured) {
      this.logger.log(`Password reset email queued for user ${user.id}`);
    } else if (resolved.type === 'phone' && smsConfigured) {
      this.logger.log(`Password reset SMS queued for user ${user.id}`);
    } else {
      this.logger.warn(
        `Password reset token created for ${user.id} but no ${resolved.type} provider configured (dev mode)`,
      );
    }

    return {
      ...generic,
      channel: resolved.type,
      ...(this.isDevExpose() ? { devHint: { token: raw } } : {}),
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const hash = this.hashToken(dto.token);
    const token = await this.prisma.authToken.findFirst({
      where: {
        tokenHash: hash,
        purpose: AuthTokenPurpose.PASSWORD_RESET,
        usedAt: null,
      },
    });
    if (!token || token.expiresAt < new Date()) {
      throw new BadRequestException({
        code: 'INVALID_TOKEN',
        message: 'Reset link or code is invalid or expired',
      });
    }
    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: token.userId },
        data: { passwordHash: await bcrypt.hash(dto.newPassword, 12) },
      }),
      this.prisma.authToken.update({
        where: { id: token.id },
        data: { usedAt: new Date() },
      }),
      this.prisma.refreshToken.updateMany({
        where: { userId: token.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);
    return { success: true };
  }

  async forgotIdentifier(dto: ForgotIdentifierDto) {
    // Never disclose whether an account exists
    return {
      success: true,
      message:
        'If we can match a recovery contact, we will send guidance. Otherwise contact support at support@silaisetu.local.',
      supportEmail:
        this.config.get('SUPPORT_EMAIL') || 'support@silaisetu.local',
      ...(dto.recoveryContact
        ? {}
        : { hint: 'Provide an alternate email or phone if you have one.' }),
    };
  }

  async requestVerification(userId: string, channel?: 'email' | 'phone') {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    const useEmail =
      channel === 'email' || (!channel && user.email && !user.emailVerifiedAt);
    const purpose = useEmail
      ? AuthTokenPurpose.EMAIL_VERIFY
      : AuthTokenPurpose.PHONE_VERIFY;
    if (useEmail && !user.email) {
      throw new BadRequestException({
        code: 'NO_EMAIL',
        message: 'No email on account',
      });
    }
    if (!useEmail && !user.phone) {
      throw new BadRequestException({
        code: 'NO_PHONE',
        message: 'No phone on account',
      });
    }

    const raw = String(randomInt(100000, 999999));
    await this.prisma.authToken.create({
      data: {
        userId,
        purpose,
        tokenHash: this.hashToken(raw),
        expiresAt: new Date(Date.now() + 10 * 60 * 1000),
      },
    });

    this.logger.warn(
      `Verification code for ${userId} (${purpose}) — provider not configured`,
    );

    return {
      success: true,
      channel: useEmail ? 'email' : 'phone',
      expiresInSec: 600,
      ...(this.isDevExpose() ? { devHint: { code: raw } } : {}),
    };
  }

  async confirmVerification(userId: string, dto: VerifyOtpDto) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    const purposes: AuthTokenPurpose[] = [
      AuthTokenPurpose.EMAIL_VERIFY,
      AuthTokenPurpose.PHONE_VERIFY,
    ];
    const hash = this.hashToken(dto.code);
    const token = await this.prisma.authToken.findFirst({
      where: {
        userId,
        purpose: { in: purposes },
        tokenHash: hash,
        usedAt: null,
      },
      orderBy: { createdAt: 'desc' },
    });
    if (!token || token.expiresAt < new Date()) {
      throw new BadRequestException({
        code: 'INVALID_OTP',
        message: 'Invalid or expired verification code',
      });
    }
    await this.prisma.$transaction([
      this.prisma.authToken.update({
        where: { id: token.id },
        data: { usedAt: new Date() },
      }),
      this.prisma.user.update({
        where: { id: userId },
        data:
          token.purpose === AuthTokenPurpose.EMAIL_VERIFY
            ? { emailVerifiedAt: new Date() }
            : { phoneVerifiedAt: new Date() },
      }),
    ]);
    return this.me(user.id);
  }

  async saveOnboardingDraft(userId: string, dto: OnboardingDraftDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        onboardingStep: dto.step,
        onboardingDraft: dto.data as Prisma.InputJsonValue,
      },
      select: {
        onboardingStep: true,
        onboardingDraft: true,
      },
    });
    return user;
  }

  async getOnboardingDraft(userId: string) {
    return this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
        onboardingStep: true,
        onboardingDraft: true,
        onboardingCompletedAt: true,
        memberships: {
          where: { isActive: true },
          select: { shopId: true, role: true },
        },
      },
    });
  }

  async completeOnboarding(userId: string, dto: CompleteOnboardingDto) {
    const existing = await this.prisma.shop.findUnique({
      where: { createIdempotencyKey: dto.idempotencyKey },
      include: { settings: true, memberships: true },
    });
    if (existing) {
      return this.toOnboardingCompleteResponse(userId, existing, true);
    }

    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    if (user.onboardingCompletedAt) {
      const membership = await this.prisma.shopMembership.findFirst({
        where: { userId, isActive: true, role: ShopRole.OWNER },
        include: { shop: { include: { settings: true } } },
      });
      if (membership) {
        return this.toOnboardingCompleteResponse(
          userId,
          membership.shop,
          true,
        );
      }
    }

    const slugBase = dto.shopName
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      .slice(0, 40) || 'shop';
    let slug = slugBase;
    if (await this.prisma.shop.findUnique({ where: { slug } })) {
      slug = `${slugBase}-${Date.now().toString(36)}`;
    }

    const address = [dto.addressLine1, dto.addressLine2, dto.area]
      .filter(Boolean)
      .join(', ');

    const shop = await this.prisma.$transaction(async (tx) => {
      const created = await tx.shop.create({
        data: {
          name: dto.shopName,
          slug,
          phone: dto.shopPhone
            ? normalizePhone(dto.shopPhone) || dto.shopPhone
            : user.phone,
          email: dto.shopEmail || user.email,
          altPhone: dto.altPhone
            ? normalizePhone(dto.altPhone) || undefined
            : undefined,
          ownerDisplayName: dto.ownerDisplayName || user.fullName,
          logoUrl: dto.logoUrl,
          description: dto.description,
          addressLine1: dto.addressLine1,
          addressLine2: dto.addressLine2,
          area: dto.area,
          address,
          city: dto.city,
          state: dto.state,
          pincode: dto.pincode,
          country: dto.country || 'IN',
          status: ShopStatus.ACTIVE,
          defaultLanguage: dto.defaultLanguage ?? LanguageCode.gu,
          measurementUnit: dto.measurementUnit ?? MeasurementUnit.INCH,
          workingHours: dto.workingHours as Prisma.InputJsonValue | undefined,
          preferences: (dto.preferences || {}) as Prisma.InputJsonValue,
          createIdempotencyKey: dto.idempotencyKey,
          onboardingCompletedAt: new Date(),
          settings: {
            create: {
              receiptHeader: dto.receiptHeader,
              receiptFooter: dto.receiptFooter,
              receiptLanguage: dto.receiptLanguage ?? LanguageCode.gu,
              receiptContact: dto.receiptContact,
              taxId: dto.taxId,
              paymentMethods: dto.paymentMethods ?? ['CASH', 'UPI'],
            },
          },
          memberships: {
            create: {
              userId,
              role: ShopRole.OWNER,
              isActive: true,
              joinedAt: new Date(),
            },
          },
          statusHistory: {
            create: {
              toStatus: ShopStatus.ACTIVE,
              reason: 'Onboarding completed',
              actorId: userId,
            },
          },
        },
        include: { settings: true, memberships: true },
      });

      // Seed default templates (aligned with GMM T-shirt / Shirt / Pant POMs)
      const n = (
        id: string,
        name: string,
        order: number,
        required = false,
      ) => ({ id, name, type: 'number' as const, required, order });
      const defaults = [
        {
          name: 'T-Shirt',
          code: 'tshirt',
          fields: [
            n('half_chest', '½ Chest', 1, true),
            n('body_length', 'Body Length', 2, true),
            n('shoulder_length', 'Shoulder Length', 3, true),
            n('sleeve_length', 'Sleeve Length', 4, true),
            n('half_waist', '½ Waist', 5),
            n('neck_opening', 'Neck Opening', 6),
            n('armhole', 'Arm Hole', 7),
            n('half_bicep', '½ Bicep', 8),
          ],
        },
        {
          name: 'Shirt',
          code: 'shirt',
          fields: [
            n('half_chest', '½ Chest', 1, true),
            n('shoulder_length_hps', 'Shoulder Length (From HPS)', 2, true),
            n('sleeve_length', 'Sleeve Length', 3, true),
            n('body_length_hps', 'Body Length (From HPS)', 4, true),
            n('neck', 'Neck / Collar', 5, true),
            n('half_waist', '½ Waist', 6),
            n('collar_stand_length', 'Collar Stand Length', 7),
            n('cuff', 'Cuff', 8),
            n('yoke', 'Yoke (Across Back)', 9),
            n('chest', 'Chest', 10),
            n('shoulder', 'Shoulder', 11),
            n('sleeve', 'Sleeve', 12),
            n('length', 'Length', 13),
          ],
        },
        {
          name: 'Trouser',
          code: 'trouser',
          fields: [
            n('half_waist', '½ Waist', 1, true),
            n('hip', 'Hip', 2, true),
            n('outseam_length', 'Length (Outseam)', 3, true),
            n('half_thigh', '½ Thigh', 4),
            n('knee', 'Knee', 5),
            n('leg_opening', 'Leg Opening', 6),
            n('inseam', 'Inseam', 7),
            n('waist', 'Waist', 8),
            n('length', 'Length', 9),
          ],
        },
      ];
      for (const t of defaults) {
        await tx.garmentTemplate.create({
          data: {
            shopId: created.id,
            name: t.name,
            code: t.code,
            fields: t.fields,
          },
        });
      }

      await tx.user.update({
        where: { id: userId },
        data: {
          onboardingStep: 6,
          onboardingCompletedAt: new Date(),
          onboardingDraft: Prisma.DbNull,
        },
      });

      return created;
    });

    return this.toOnboardingCompleteResponse(userId, shop, false);
  }

  /** Re-issue JWT so X-Shop-Id membership claims are present after shop create. */
  private async toOnboardingCompleteResponse(
    userId: string,
    shop: unknown,
    resumed: boolean,
  ) {
    const tokens = await this.issueTokens(userId);
    const profile = await this.me(userId);
    return {
      shop,
      resumed,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: profile,
    };
  }

  private wrapAuth(
    profile: Awaited<ReturnType<AuthService['me']>>,
    tokens: Awaited<ReturnType<AuthService['issueTokens']>>,
  ) {
    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: profile,
    };
  }

  private async toAuthResponse(
    userId: string,
    tokens: Awaited<ReturnType<AuthService['issueTokens']>>,
  ) {
    const profile = await this.me(userId);
    return this.wrapAuth(profile, tokens);
  }
}
