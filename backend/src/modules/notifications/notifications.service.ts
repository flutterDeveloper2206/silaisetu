import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import {
  NotificationType,
  OrderStatus,
  Prisma,
  ShopRole,
} from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private readonly prisma: PrismaService) {}

  list(userId: string, shopId?: string) {
    return this.prisma.notification.findMany({
      where: {
        userId,
        ...(shopId ? { shopId } : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async markRead(userId: string, id: string) {
    await this.prisma.notification.updateMany({
      where: { id, userId },
      data: { isRead: true },
    });
    return { success: true };
  }

  markAllRead(userId: string) {
    return this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }

  /** IST morning-ish: 02:30 UTC ≈ 08:00 IST */
  @Cron('30 2 * * *')
  async scheduledDeliveryReminders() {
    try {
      const result = await this.createDeliveryReminders();
      this.logger.log(
        `Delivery reminders: created=${result.created} scanned=${result.scanned}`,
      );
    } catch (e) {
      this.logger.error(
        `Delivery reminder cron failed: ${e instanceof Error ? e.message : e}`,
      );
    }
  }

  async createDeliveryReminders() {
    const now = new Date();
    const todayStart = new Date(now);
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date(now);
    todayEnd.setHours(23, 59, 59, 999);
    const dayKey = todayStart.toISOString().slice(0, 10);

    const openStatuses: OrderStatus[] = [
      OrderStatus.NEW,
      OrderStatus.CUTTING,
      OrderStatus.STITCHING,
      OrderStatus.TRIAL,
      OrderStatus.READY,
    ];

    const orders = await this.prisma.stitchingOrder.findMany({
      where: {
        status: { in: openStatuses },
        deliveryDate: { not: null, lte: todayEnd },
      },
      select: {
        id: true,
        shopId: true,
        orderNumber: true,
        deliveryDate: true,
        customer: { select: { fullName: true } },
      },
    });

    let created = 0;
    for (const order of orders) {
      try {
        const delivery = order.deliveryDate!;
        const isOverdue = delivery < todayStart;
        const type = isOverdue
          ? NotificationType.OVERDUE
          : NotificationType.DELIVERY_REMINDER;
        const deliveryIso = delivery.toISOString().slice(0, 10);
        const title = isOverdue ? 'Overdue delivery' : "Today's delivery";
        const body = isOverdue
          ? `${order.orderNumber} for ${order.customer.fullName} was due ${deliveryIso}`
          : `${order.orderNumber} for ${order.customer.fullName} is due today`;

        const recipients = await this.prisma.shopMembership.findMany({
          where: {
            shopId: order.shopId,
            isActive: true,
            role: { in: [ShopRole.OWNER, ShopRole.MANAGER] },
          },
          select: { userId: true },
        });

        for (const r of recipients) {
          const recent = await this.prisma.notification.findMany({
            where: {
              userId: r.userId,
              shopId: order.shopId,
              type,
              createdAt: { gte: todayStart },
            },
            select: { payload: true },
            take: 100,
          });
          const already = recent.some((n) => {
            const p = n.payload as Record<string, unknown> | null;
            return p?.orderId === order.id && p?.dayKey === dayKey;
          });
          if (already) continue;

          await this.prisma.notification.create({
            data: {
              shopId: order.shopId,
              userId: r.userId,
              type,
              title,
              body,
              payload: {
                orderId: order.id,
                orderNumber: order.orderNumber,
                deliveryDate: deliveryIso,
                dayKey,
              } as Prisma.InputJsonValue,
            },
          });
          created += 1;
        }
      } catch (e) {
        this.logger.warn(
          `Reminder skip for order ${order.id}: ${e instanceof Error ? e.message : e}`,
        );
      }
    }

    return { created, scanned: orders.length, dayKey };
  }
}
