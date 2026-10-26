import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PaymentKind, PaymentMethod, Prisma } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  private shopId() {
    return requireShopContext().shopId;
  }

  async record(
    userId: string,
    data: {
      orderId: string;
      amount: string | number;
      kind: PaymentKind;
      method?: PaymentMethod;
      reference?: string;
      notes?: string;
      idempotencyKey?: string;
    },
  ) {
    const shopId = this.shopId();
    const amount = new Decimal(data.amount);
    if (amount.lte(0) && data.kind !== PaymentKind.REVERSAL) {
      throw new BadRequestException({
        code: 'INVALID_AMOUNT',
        message: 'Amount must be positive',
      });
    }

    if (data.idempotencyKey) {
      const existing = await this.prisma.payment.findUnique({
        where: {
          shopId_idempotencyKey: { shopId, idempotencyKey: data.idempotencyKey },
        },
      });
      if (existing) return existing;
    }

    return this.prisma.$transaction(async (tx) => {
      const order = await tx.stitchingOrder.findFirst({
        where: { id: data.orderId, shopId },
      });
      if (!order) {
        throw new NotFoundException({
          code: 'ORDER_NOT_FOUND',
          message: 'Order not found',
        });
      }

      const payment = await tx.payment.create({
        data: {
          shopId,
          orderId: order.id,
          customerId: order.customerId,
          amount,
          kind: data.kind,
          method: data.method ?? PaymentMethod.CASH,
          reference: data.reference,
          notes: data.notes,
          idempotencyKey: data.idempotencyKey,
          recordedById: userId,
        },
      });

      await this.recalculate(tx, order.id);
      return payment;
    });
  }

  async reverse(userId: string, paymentId: string, reason?: string) {
    const shopId = this.shopId();
    return this.prisma.$transaction(async (tx) => {
      const original = await tx.payment.findFirst({
        where: { id: paymentId, shopId },
      });
      if (!original || original.isReversed) {
        throw new BadRequestException({
          code: 'PAYMENT_NOT_REVERSIBLE',
          message: 'Payment cannot be reversed',
        });
      }
      await tx.payment.update({
        where: { id: original.id },
        data: { isReversed: true },
      });
      const reversal = await tx.payment.create({
        data: {
          shopId,
          orderId: original.orderId,
          customerId: original.customerId,
          amount: original.amount.neg(),
          kind: PaymentKind.REVERSAL,
          method: original.method,
          notes: reason,
          reversesPaymentId: original.id,
          recordedById: userId,
        },
      });
      await this.recalculate(tx, original.orderId);
      return reversal;
    });
  }

  private async recalculate(tx: Prisma.TransactionClient, orderId: string) {
    const payments = await tx.payment.findMany({
      where: { orderId, isReversed: false, kind: { not: PaymentKind.REVERSAL } },
    });
    const reversals = await tx.payment.findMany({
      where: { orderId, kind: PaymentKind.REVERSAL },
    });
    let paid = new Decimal(0);
    for (const p of payments) paid = paid.add(p.amount);
    for (const r of reversals) paid = paid.add(r.amount); // negative

    const order = await tx.stitchingOrder.findUniqueOrThrow({
      where: { id: orderId },
    });
    const balanceDue = Decimal.max(order.totalAmount.sub(paid), new Decimal(0));
    await tx.stitchingOrder.update({
      where: { id: orderId },
      data: { amountPaid: paid, balanceDue },
    });
  }

  listByOrder(orderId: string) {
    return this.prisma.payment.findMany({
      where: { shopId: this.shopId(), orderId },
      orderBy: { createdAt: 'desc' },
    });
  }

  receipt(paymentId: string) {
    return this.prisma.payment.findFirst({
      where: { id: paymentId, shopId: this.shopId() },
      include: {
        order: { select: { orderNumber: true, totalAmount: true, balanceDue: true } },
        customer: { select: { fullName: true, phone: true } },
        shop: { select: { name: true, phone: true, address: true } },
      },
    });
  }
}
