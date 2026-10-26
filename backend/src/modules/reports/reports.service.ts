import { Injectable } from '@nestjs/common';
import { OrderStatus, PaymentKind } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  private shopId() {
    return requireShopContext().shopId;
  }

  async summary(from?: string, to?: string) {
    const shopId = this.shopId();
    const createdAt =
      from || to
        ? {
            ...(from ? { gte: new Date(from) } : {}),
            ...(to ? { lte: new Date(to) } : {}),
          }
        : undefined;

    const [ordersByStatus, orderAgg, payments, outstanding] = await Promise.all([
      this.prisma.stitchingOrder.groupBy({
        by: ['status'],
        where: { shopId, ...(createdAt ? { createdAt } : {}) },
        _count: true,
      }),
      this.prisma.stitchingOrder.aggregate({
        where: { shopId, ...(createdAt ? { createdAt } : {}) },
        _sum: { totalAmount: true },
        _count: true,
      }),
      this.prisma.payment.aggregate({
        where: {
          shopId,
          isReversed: false,
          kind: { not: PaymentKind.REVERSAL },
          ...(createdAt ? { createdAt } : {}),
        },
        _sum: { amount: true },
        _count: true,
      }),
      this.prisma.stitchingOrder.aggregate({
        where: {
          shopId,
          balanceDue: { gt: 0 },
          status: { not: OrderStatus.CANCELLED },
        },
        _sum: { balanceDue: true },
        _count: true,
      }),
    ]);

    return {
      ordersCount: orderAgg._count,
      orderValue: orderAgg._sum.totalAmount ?? 0,
      revenueReceived: payments._sum.amount ?? 0,
      paymentsCount: payments._count,
      outstandingBalance: outstanding._sum.balanceDue ?? 0,
      outstandingOrders: outstanding._count,
      ordersByStatus,
      note: 'orderValue is booked order totals; revenueReceived is sum of recorded payments',
    };
  }

  async csvOrders(from?: string, to?: string) {
    const shopId = this.shopId();
    const orders = await this.prisma.stitchingOrder.findMany({
      where: {
        shopId,
        ...(from || to
          ? {
              createdAt: {
                ...(from ? { gte: new Date(from) } : {}),
                ...(to ? { lte: new Date(to) } : {}),
              },
            }
          : {}),
      },
      include: { customer: { select: { fullName: true, phone: true } } },
      orderBy: { createdAt: 'desc' },
      take: 5000,
    });

    const header =
      'orderNumber,customer,phone,status,totalAmount,amountPaid,balanceDue,deliveryDate,createdAt';
    const rows = orders.map((o) =>
      [
        o.orderNumber,
        JSON.stringify(o.customer.fullName),
        o.customer.phone,
        o.status,
        o.totalAmount.toString(),
        o.amountPaid.toString(),
        o.balanceDue.toString(),
        o.deliveryDate?.toISOString() ?? '',
        o.createdAt.toISOString(),
      ].join(','),
    );
    return [header, ...rows].join('\n');
  }
}
