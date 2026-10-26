import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { AuditAction, ShopStatus } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class PlatformAdminService {
  constructor(private readonly prisma: PrismaService) {}

  async dashboard() {
    const [
      totalShops,
      activeShops,
      suspendedShops,
      pendingShops,
      totalUsers,
      recentShops,
      recentAudits,
    ] = await Promise.all([
      this.prisma.shop.count(),
      this.prisma.shop.count({ where: { status: ShopStatus.ACTIVE } }),
      this.prisma.shop.count({ where: { status: ShopStatus.SUSPENDED } }),
      this.prisma.shop.count({ where: { status: ShopStatus.PENDING } }),
      this.prisma.user.count(),
      this.prisma.shop.findMany({
        orderBy: { createdAt: 'desc' },
        take: 8,
        select: {
          id: true,
          name: true,
          status: true,
          city: true,
          createdAt: true,
        },
      }),
      this.prisma.auditLog.findMany({
        orderBy: { createdAt: 'desc' },
        take: 10,
        include: {
          actor: { select: { id: true, fullName: true, email: true } },
        },
      }),
    ]);

    return {
      totals: {
        shops: totalShops,
        activeShops,
        suspendedShops,
        pendingShops,
        users: totalUsers,
      },
      recentShops,
      recentEvents: recentAudits,
    };
  }

  async listShops(query: {
    search?: string;
    status?: ShopStatus;
    page?: number;
    pageSize?: number;
  }) {
    const page = Math.max(1, query.page ?? 1);
    const pageSize = Math.min(100, query.pageSize ?? 20);
    const where = {
      ...(query.status ? { status: query.status } : {}),
      ...(query.search
        ? {
            OR: [
              { name: { contains: query.search, mode: 'insensitive' as const } },
              { slug: { contains: query.search, mode: 'insensitive' as const } },
              { email: { contains: query.search, mode: 'insensitive' as const } },
            ],
          }
        : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.shop.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          _count: { select: { memberships: true, customers: true, orders: true } },
        },
      }),
      this.prisma.shop.count({ where }),
    ]);
    return { items, total, page, pageSize };
  }

  async getShop(id: string) {
    const shop = await this.prisma.shop.findUnique({
      where: { id },
      include: {
        memberships: {
          include: {
            user: {
              select: { id: true, fullName: true, email: true, isActive: true },
            },
          },
        },
        statusHistory: { orderBy: { createdAt: 'desc' } },
        _count: { select: { customers: true, orders: true } },
      },
    });
    if (!shop) {
      throw new NotFoundException({
        code: 'SHOP_NOT_FOUND',
        message: 'Shop not found',
      });
    }
    // Intentionally omit private measurements / payment details
    return shop;
  }

  async changeShopStatus(
    actorId: string,
    shopId: string,
    toStatus: ShopStatus,
    reason?: string,
  ) {
    if (
      ![ShopStatus.ACTIVE, ShopStatus.SUSPENDED, ShopStatus.PENDING].includes(
        toStatus,
      )
    ) {
      throw new ForbiddenException({
        code: 'INVALID_STATUS',
        message: 'Invalid shop status',
      });
    }

    return this.prisma.$transaction(async (tx) => {
      const shop = await tx.shop.findUnique({ where: { id: shopId } });
      if (!shop) {
        throw new NotFoundException({
          code: 'SHOP_NOT_FOUND',
          message: 'Shop not found',
        });
      }
      const updated = await tx.shop.update({
        where: { id: shopId },
        data: { status: toStatus },
      });
      await tx.shopStatusHistory.create({
        data: {
          shopId,
          fromStatus: shop.status,
          toStatus,
          reason,
          actorId,
        },
      });

      let action: AuditAction = AuditAction.OTHER;
      if (toStatus === ShopStatus.SUSPENDED) action = AuditAction.SHOP_SUSPENDED;
      if (toStatus === ShopStatus.ACTIVE && shop.status === ShopStatus.SUSPENDED) {
        action = AuditAction.SHOP_REACTIVATED;
      } else if (toStatus === ShopStatus.ACTIVE) {
        action = AuditAction.SHOP_ACTIVATED;
      }

      await tx.auditLog.create({
        data: {
          shopId,
          actorId,
          action,
          targetType: 'Shop',
          targetId: shopId,
          reason,
          metadata: { from: shop.status, to: toStatus },
        },
      });

      return updated;
    });
  }

  async listUsers(page = 1, pageSize = 20, search?: string) {
    const where = search
      ? {
          OR: [
            { email: { contains: search, mode: 'insensitive' as const } },
            { fullName: { contains: search, mode: 'insensitive' as const } },
          ],
        }
      : {};
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        select: {
          id: true,
          email: true,
          fullName: true,
          phone: true,
          isActive: true,
          createdAt: true,
          platformAdmin: { select: { id: true } },
          memberships: {
            select: {
              role: true,
              isActive: true,
              shop: { select: { id: true, name: true, status: true } },
            },
          },
        },
      }),
      this.prisma.user.count({ where }),
    ]);
    return { items, total, page, pageSize };
  }

  async auditLogs(page = 1, pageSize = 50) {
    const [items, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          actor: { select: { id: true, fullName: true, email: true } },
          shop: { select: { id: true, name: true } },
        },
      }),
      this.prisma.auditLog.count(),
    ]);
    return { items, total, page, pageSize };
  }

  async getSettings() {
    return this.prisma.platformSettings.findMany();
  }

  async upsertSetting(actorId: string, key: string, value: object) {
    const setting = await this.prisma.platformSettings.upsert({
      where: { key },
      create: { key, value },
      update: { value },
    });
    await this.prisma.auditLog.create({
      data: {
        actorId,
        action: AuditAction.PLATFORM_SETTINGS_CHANGED,
        targetType: 'PlatformSettings',
        targetId: setting.id,
        metadata: { key },
      },
    });
    return setting;
  }

  async health() {
    let dbOk = false;
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      dbOk = true;
    } catch {
      dbOk = false;
    }
    return {
      api: 'ok',
      database: dbOk ? 'ok' : 'error',
      version: process.env.APP_VERSION || '0.1.0',
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString(),
    };
  }
}
