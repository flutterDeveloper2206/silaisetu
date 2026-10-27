import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AuditAction,
  Prisma,
  SubscriptionProofStatus,
} from '@prisma/client';
import { createHash, randomUUID } from 'crypto';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { PrismaService } from '../../common/prisma/prisma.service';
import {
  DEFAULT_SUBSCRIPTION_CONFIG,
  SUBSCRIPTION_SETTING_KEYS,
  SubscriptionConfig,
  unwrapSettingValue,
  wrapSettingValue,
} from './subscription.config';

@Injectable()
export class SubscriptionService {
  constructor(private readonly prisma: PrismaService) {}

  async getConfig(): Promise<SubscriptionConfig> {
    const keys = Object.values(SUBSCRIPTION_SETTING_KEYS);
    const rows = await this.prisma.platformSettings.findMany({
      where: { key: { in: keys } },
    });
    const map = new Map(rows.map((r) => [r.key, unwrapSettingValue(r.value)]));
    const num = (key: string, fallback: number) => {
      const v = map.get(key);
      const n = typeof v === 'number' ? v : Number(v);
      return Number.isFinite(n) ? n : fallback;
    };
    const str = (key: string, fallback: string) => {
      const v = map.get(key);
      return typeof v === 'string' ? v : fallback;
    };
    const bool = (key: string, fallback: boolean) => {
      const v = map.get(key);
      if (typeof v === 'boolean') return v;
      if (v === 'true' || v === 1) return true;
      if (v === 'false' || v === 0) return false;
      return fallback;
    };
    return {
      enabled: bool(
        SUBSCRIPTION_SETTING_KEYS.enabled,
        DEFAULT_SUBSCRIPTION_CONFIG.enabled,
      ),
      trialDays: num(
        SUBSCRIPTION_SETTING_KEYS.trialDays,
        DEFAULT_SUBSCRIPTION_CONFIG.trialDays,
      ),
      paidDays: num(
        SUBSCRIPTION_SETTING_KEYS.paidDays,
        DEFAULT_SUBSCRIPTION_CONFIG.paidDays,
      ),
      amountInr: num(
        SUBSCRIPTION_SETTING_KEYS.amountInr,
        DEFAULT_SUBSCRIPTION_CONFIG.amountInr,
      ),
      upiId: str(
        SUBSCRIPTION_SETTING_KEYS.upiId,
        DEFAULT_SUBSCRIPTION_CONFIG.upiId,
      ),
      qrImageUrl: str(
        SUBSCRIPTION_SETTING_KEYS.qrImageUrl,
        DEFAULT_SUBSCRIPTION_CONFIG.qrImageUrl,
      ),
      instructions: str(
        SUBSCRIPTION_SETTING_KEYS.instructions,
        DEFAULT_SUBSCRIPTION_CONFIG.instructions,
      ),
    };
  }

  async saveConfig(
    actorId: string,
    partial: Partial<SubscriptionConfig>,
  ): Promise<SubscriptionConfig> {
    const entries: Array<[string, unknown]> = [];
    if (partial.enabled !== undefined) {
      entries.push([SUBSCRIPTION_SETTING_KEYS.enabled, partial.enabled]);
    }
    if (partial.trialDays !== undefined) {
      entries.push([SUBSCRIPTION_SETTING_KEYS.trialDays, partial.trialDays]);
    }
    if (partial.paidDays !== undefined) {
      entries.push([SUBSCRIPTION_SETTING_KEYS.paidDays, partial.paidDays]);
    }
    if (partial.amountInr !== undefined) {
      entries.push([SUBSCRIPTION_SETTING_KEYS.amountInr, partial.amountInr]);
    }
    if (partial.upiId !== undefined) {
      entries.push([SUBSCRIPTION_SETTING_KEYS.upiId, partial.upiId]);
    }
    if (partial.qrImageUrl !== undefined) {
      entries.push([SUBSCRIPTION_SETTING_KEYS.qrImageUrl, partial.qrImageUrl]);
    }
    if (partial.instructions !== undefined) {
      entries.push([
        SUBSCRIPTION_SETTING_KEYS.instructions,
        partial.instructions,
      ]);
    }
    for (const [key, value] of entries) {
      const setting = await this.prisma.platformSettings.upsert({
        where: { key },
        create: { key, value: wrapSettingValue(value) as Prisma.InputJsonValue },
        update: { value: wrapSettingValue(value) as Prisma.InputJsonValue },
      });
      await this.prisma.auditLog.create({
        data: {
          actorId,
          action: AuditAction.PLATFORM_SETTINGS_CHANGED,
          targetType: 'PlatformSettings',
          targetId: setting.id,
          metadata: {
            key,
            value: value as Prisma.InputJsonValue,
          },
        },
      });
    }
    return this.getConfig();
  }

  trialEndsAtFromNow(trialDays: number, from = new Date()): Date {
    const d = new Date(from);
    d.setUTCDate(d.getUTCDate() + Math.max(0, trialDays));
    return d;
  }

  isShopAllowed(
    shop: {
      subscriptionLifetimeFree: boolean;
      trialEndsAt: Date | null;
      subscriptionExpiresAt: Date | null;
    },
    config: SubscriptionConfig,
    now = new Date(),
  ): boolean {
    if (!config.enabled) return true;
    if (shop.subscriptionLifetimeFree) return true;
    if (shop.trialEndsAt && shop.trialEndsAt > now) return true;
    if (shop.subscriptionExpiresAt && shop.subscriptionExpiresAt > now) {
      return true;
    }
    return false;
  }

  async assertShopAllowed(shopId: string): Promise<void> {
    const config = await this.getConfig();
    if (!config.enabled) return;
    const shop = await this.prisma.shop.findUnique({
      where: { id: shopId },
      select: {
        subscriptionLifetimeFree: true,
        trialEndsAt: true,
        subscriptionExpiresAt: true,
      },
    });
    if (!shop) {
      throw new NotFoundException({
        code: 'SHOP_NOT_FOUND',
        message: 'Shop not found',
      });
    }
    if (!this.isShopAllowed(shop, config)) {
      throw new ForbiddenException({
        code: 'SUBSCRIPTION_REQUIRED',
        message:
          'Subscription required. Pay via QR and submit proof to continue.',
      });
    }
  }

  async getStatusForShop(shopId: string, userId: string) {
    const membership = await this.prisma.shopMembership.findFirst({
      where: { shopId, userId, isActive: true },
    });
    if (!membership) {
      throw new ForbiddenException({
        code: 'NOT_A_MEMBER',
        message: 'Not a member of this shop',
      });
    }
    const shop = await this.prisma.shop.findUnique({ where: { id: shopId } });
    if (!shop) {
      throw new NotFoundException({
        code: 'SHOP_NOT_FOUND',
        message: 'Shop not found',
      });
    }
    const config = await this.getConfig();
    const allowed = this.isShopAllowed(shop, config);
    const pending = await this.prisma.subscriptionPaymentProof.findFirst({
      where: { shopId, status: SubscriptionProofStatus.PENDING },
      orderBy: { createdAt: 'desc' },
    });
    const latest = await this.prisma.subscriptionPaymentProof.findFirst({
      where: { shopId },
      orderBy: { createdAt: 'desc' },
    });
    return {
      required: config.enabled && !allowed,
      allowed,
      enabled: config.enabled,
      lifetimeFree: shop.subscriptionLifetimeFree,
      trialEndsAt: shop.trialEndsAt,
      subscriptionExpiresAt: shop.subscriptionExpiresAt,
      pendingProof: pending
        ? {
            id: pending.id,
            status: pending.status,
            transactionId: pending.transactionId,
            createdAt: pending.createdAt,
          }
        : null,
      latestProof: latest
        ? {
            id: latest.id,
            status: latest.status,
            transactionId: latest.transactionId,
            reviewNote: latest.reviewNote,
            createdAt: latest.createdAt,
            reviewedAt: latest.reviewedAt,
          }
        : null,
      config: {
        amountInr: config.amountInr,
        paidDays: config.paidDays,
        trialDays: config.trialDays,
        upiId: config.upiId,
        qrImageUrl: config.qrImageUrl,
        instructions: config.instructions,
      },
    };
  }

  saveScreenshot(file: Express.Multer.File): string {
    const dir = join(process.cwd(), 'uploads', 'subscription');
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
    const ext =
      (file.originalname.split('.').pop() || 'jpg').toLowerCase().replace(
        /[^a-z0-9]/g,
        '',
      ) || 'jpg';
    const name = `${randomUUID()}.${ext}`;
    writeFileSync(join(dir, name), file.buffer);
    return `/uploads/subscription/${name}`;
  }

  async submitProof(params: {
    shopId: string;
    userId: string;
    transactionId: string;
    amountInr?: number;
    note?: string;
    file: Express.Multer.File;
  }) {
    const membership = await this.prisma.shopMembership.findFirst({
      where: {
        shopId: params.shopId,
        userId: params.userId,
        isActive: true,
      },
    });
    if (!membership) {
      throw new ForbiddenException({
        code: 'NOT_A_MEMBER',
        message: 'Not a member of this shop',
      });
    }
    const txn = params.transactionId.trim();
    if (txn.length < 4) {
      throw new BadRequestException({
        code: 'INVALID_TRANSACTION_ID',
        message: 'Transaction ID is required',
      });
    }
    if (!params.file?.buffer?.length) {
      throw new BadRequestException({
        code: 'SCREENSHOT_REQUIRED',
        message: 'Payment screenshot is required',
      });
    }
    const existingPending =
      await this.prisma.subscriptionPaymentProof.findFirst({
        where: {
          shopId: params.shopId,
          status: SubscriptionProofStatus.PENDING,
        },
      });
    if (existingPending) {
      throw new BadRequestException({
        code: 'PROOF_ALREADY_PENDING',
        message: 'A payment proof is already awaiting review',
      });
    }
    const config = await this.getConfig();
    const amount = params.amountInr ?? config.amountInr;
    const screenshotUrl = this.saveScreenshot(params.file);
    const proof = await this.prisma.subscriptionPaymentProof.create({
      data: {
        shopId: params.shopId,
        submittedById: params.userId,
        amountInr: new Prisma.Decimal(amount),
        transactionId: txn,
        screenshotUrl,
        note: params.note?.trim() || null,
      },
    });
    await this.prisma.auditLog.create({
      data: {
        shopId: params.shopId,
        actorId: params.userId,
        action: AuditAction.SUBSCRIPTION_PROOF_SUBMITTED,
        targetType: 'SubscriptionPaymentProof',
        targetId: proof.id,
        metadata: {
          transactionId: txn,
          amountInr: amount,
          // fingerprint only — never log screenshot bytes
          screenshotHash: createHash('sha256')
            .update(params.file.buffer)
            .digest('hex')
            .slice(0, 16),
        },
      },
    });
    return proof;
  }

  async listProofs(query: {
    status?: SubscriptionProofStatus;
    page?: number;
    pageSize?: number;
  }) {
    const page = Math.max(1, query.page ?? 1);
    const pageSize = Math.min(100, query.pageSize ?? 20);
    const where = query.status ? { status: query.status } : {};
    const [items, total] = await Promise.all([
      this.prisma.subscriptionPaymentProof.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          shop: { select: { id: true, name: true, slug: true } },
          submittedBy: {
            select: { id: true, fullName: true, email: true, phone: true },
          },
          reviewedBy: {
            select: { id: true, fullName: true, email: true },
          },
        },
      }),
      this.prisma.subscriptionPaymentProof.count({ where }),
    ]);
    return { items, total, page, pageSize };
  }

  async approveProof(actorId: string, proofId: string, reviewNote?: string) {
    const proof = await this.prisma.subscriptionPaymentProof.findUnique({
      where: { id: proofId },
    });
    if (!proof) {
      throw new NotFoundException({
        code: 'PROOF_NOT_FOUND',
        message: 'Payment proof not found',
      });
    }
    if (proof.status !== SubscriptionProofStatus.PENDING) {
      throw new BadRequestException({
        code: 'PROOF_NOT_PENDING',
        message: 'Only pending proofs can be approved',
      });
    }
    const config = await this.getConfig();
    const shop = await this.prisma.shop.findUnique({
      where: { id: proof.shopId },
    });
    if (!shop) {
      throw new NotFoundException({
        code: 'SHOP_NOT_FOUND',
        message: 'Shop not found',
      });
    }
    const now = new Date();
    const base =
      shop.subscriptionExpiresAt && shop.subscriptionExpiresAt > now
        ? shop.subscriptionExpiresAt
        : now;
    const expires = new Date(base);
    expires.setUTCDate(expires.getUTCDate() + Math.max(1, config.paidDays));

    const [updatedProof, updatedShop] = await this.prisma.$transaction([
      this.prisma.subscriptionPaymentProof.update({
        where: { id: proofId },
        data: {
          status: SubscriptionProofStatus.APPROVED,
          reviewedById: actorId,
          reviewedAt: now,
          reviewNote: reviewNote?.trim() || null,
        },
      }),
      this.prisma.shop.update({
        where: { id: proof.shopId },
        data: { subscriptionExpiresAt: expires },
      }),
      this.prisma.auditLog.create({
        data: {
          shopId: proof.shopId,
          actorId,
          action: AuditAction.SUBSCRIPTION_PROOF_APPROVED,
          targetType: 'SubscriptionPaymentProof',
          targetId: proofId,
          reason: reviewNote,
          metadata: {
            subscriptionExpiresAt: expires.toISOString(),
            paidDays: config.paidDays,
          },
        },
      }),
    ]);
    return { proof: updatedProof, shop: updatedShop };
  }

  async rejectProof(actorId: string, proofId: string, reviewNote?: string) {
    const proof = await this.prisma.subscriptionPaymentProof.findUnique({
      where: { id: proofId },
    });
    if (!proof) {
      throw new NotFoundException({
        code: 'PROOF_NOT_FOUND',
        message: 'Payment proof not found',
      });
    }
    if (proof.status !== SubscriptionProofStatus.PENDING) {
      throw new BadRequestException({
        code: 'PROOF_NOT_PENDING',
        message: 'Only pending proofs can be rejected',
      });
    }
    const updated = await this.prisma.subscriptionPaymentProof.update({
      where: { id: proofId },
      data: {
        status: SubscriptionProofStatus.REJECTED,
        reviewedById: actorId,
        reviewedAt: new Date(),
        reviewNote: reviewNote?.trim() || null,
      },
    });
    await this.prisma.auditLog.create({
      data: {
        shopId: proof.shopId,
        actorId,
        action: AuditAction.SUBSCRIPTION_PROOF_REJECTED,
        targetType: 'SubscriptionPaymentProof',
        targetId: proofId,
        reason: reviewNote,
      },
    });
    return updated;
  }

  async updateShopSubscription(
    actorId: string,
    shopId: string,
    data: {
      subscriptionLifetimeFree?: boolean;
      trialEndsAt?: string | null;
      subscriptionExpiresAt?: string | null;
    },
  ) {
    const shop = await this.prisma.shop.findUnique({ where: { id: shopId } });
    if (!shop) {
      throw new NotFoundException({
        code: 'SHOP_NOT_FOUND',
        message: 'Shop not found',
      });
    }
    const updated = await this.prisma.shop.update({
      where: { id: shopId },
      data: {
        ...(data.subscriptionLifetimeFree !== undefined
          ? { subscriptionLifetimeFree: data.subscriptionLifetimeFree }
          : {}),
        ...(data.trialEndsAt !== undefined
          ? {
              trialEndsAt:
                data.trialEndsAt === null || data.trialEndsAt === ''
                  ? null
                  : new Date(data.trialEndsAt),
            }
          : {}),
        ...(data.subscriptionExpiresAt !== undefined
          ? {
              subscriptionExpiresAt:
                data.subscriptionExpiresAt === null ||
                data.subscriptionExpiresAt === ''
                  ? null
                  : new Date(data.subscriptionExpiresAt),
            }
          : {}),
      },
    });
    await this.prisma.auditLog.create({
      data: {
        shopId,
        actorId,
        action: AuditAction.PLATFORM_SETTINGS_CHANGED,
        targetType: 'ShopSubscription',
        targetId: shopId,
        metadata: data as Prisma.InputJsonValue,
      },
    });
    return updated;
  }
}
