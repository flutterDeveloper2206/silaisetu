import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Request } from 'express';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { tenantStorage } from '../../common/tenant/tenant-context';
import { JwtPayload } from './auth.types';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>('JWT_ACCESS_SECRET'),
      passReqToCallback: true,
    });
  }

  async validate(req: Request, payload: JwtPayload) {
    const shopHeader = req.header('x-shop-id') || undefined;
    let shopId: string | undefined;
    let shopRole = undefined as JwtPayload['memberships'][0]['role'] | undefined;
    let shopStatus: string | undefined;

    if (shopHeader) {
      // Prefer memberships embedded in the access token.
      const membership = payload.memberships?.find(
        (m) => m.shopId === shopHeader,
      );
      if (membership) {
        shopId = membership.shopId;
        shopRole = membership.role;
        shopStatus = membership.status;
      } else {
        // Stale JWT (e.g. issued before onboarding created the shop).
        // Resolve live membership from DB so X-Shop-Id still works.
        const live = await this.prisma.shopMembership.findFirst({
          where: {
            userId: payload.sub,
            shopId: shopHeader,
            isActive: true,
          },
          include: { shop: { select: { status: true } } },
        });
        if (live) {
          shopId = live.shopId;
          shopRole = live.role;
          shopStatus = live.shop.status;
        }
      }

      if (shopId) {
        const shop = await this.prisma.shop.findUnique({
          where: { id: shopId },
          select: { status: true },
        });
        shopStatus = shop?.status ?? shopStatus;
      }
    }

    const store = {
      userId: payload.sub,
      email: payload.email,
      isPlatformAdmin: payload.isPlatformAdmin,
      shopId,
      shopRole,
      shopStatus,
    };

    // Bind ALS for the remainder of the request via middleware-like attach
    tenantStorage.enterWith(store);

    return {
      ...payload,
      shopId,
      shopRole,
      shopStatus,
    };
  }
}
