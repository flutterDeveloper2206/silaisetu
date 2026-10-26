import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus, Prisma } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';
import { canTransition } from './order-status';

type ItemInput = {
  garmentTemplateId?: string;
  garmentName: string;
  quantity: number;
  unitPrice: string | number;
  styleNotes?: string;
  fabricInfo?: string;
  measurementRecordId?: string;
};

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  private shopId() {
    return requireShopContext().shopId;
  }

  private async nextOrderNumber(shopId: string, tx: Prisma.TransactionClient) {
    const count = await tx.stitchingOrder.count({ where: { shopId } });
    const year = new Date().getFullYear();
    return `SS-${year}-${String(count + 1).padStart(5, '0')}`;
  }

  async create(
    userId: string,
    data: {
      customerId: string;
      items: ItemInput[];
      trialDate?: string;
      deliveryDate?: string;
      discount?: string | number;
      notes?: string;
      assignedToId?: string;
      advanceAmount?: string | number;
      advanceMethod?: string;
      idempotencyKey?: string;
    },
  ) {
    const shopId = this.shopId();
    if (!data.items?.length) {
      throw new BadRequestException({
        code: 'ORDER_ITEMS_REQUIRED',
        message: 'At least one item is required',
      });
    }

    const customer = await this.prisma.customer.findFirst({
      where: { id: data.customerId, shopId },
    });
    if (!customer) {
      throw new NotFoundException({
        code: 'CUSTOMER_NOT_FOUND',
        message: 'Customer not found',
      });
    }

    return this.prisma.$transaction(async (tx) => {
      let subtotal = new Decimal(0);
      const itemRows: Prisma.OrderItemCreateWithoutOrderInput[] = [];

      for (const item of data.items) {
        const qty = item.quantity || 1;
        const unit = new Decimal(item.unitPrice);
        const line = unit.mul(qty);
        subtotal = subtotal.add(line);

        let snapshot: object | undefined;
        if (item.measurementRecordId) {
          const m = await tx.measurementRecord.findFirst({
            where: {
              id: item.measurementRecordId,
              shopId,
              customerId: data.customerId,
            },
            include: { garmentTemplate: true },
          });
          if (m) {
            snapshot = {
              measurementRecordId: m.id,
              version: m.version,
              unit: m.unit,
              values: m.values,
              template: {
                id: m.garmentTemplate.id,
                name: m.garmentTemplate.name,
                code: m.garmentTemplate.code,
                version: m.garmentTemplate.version,
                fields: m.garmentTemplate.fields,
              },
              capturedAt: new Date().toISOString(),
            };
          }
        } else if (item.garmentTemplateId) {
          const template = await tx.garmentTemplate.findFirst({
            where: { id: item.garmentTemplateId, shopId },
          });
          if (template) {
            const latest = await tx.measurementRecord.findFirst({
              where: {
                shopId,
                customerId: data.customerId,
                garmentTemplateId: template.id,
              },
              orderBy: { version: 'desc' },
            });
            if (latest) {
              snapshot = {
                measurementRecordId: latest.id,
                version: latest.version,
                unit: latest.unit,
                values: latest.values,
                template: {
                  id: template.id,
                  name: template.name,
                  code: template.code,
                  version: template.version,
                  fields: template.fields,
                },
                capturedAt: new Date().toISOString(),
              };
            }
          }
        }

        itemRows.push({
          garmentTemplate: item.garmentTemplateId
            ? { connect: { id: item.garmentTemplateId } }
            : undefined,
          garmentName: item.garmentName,
          quantity: qty,
          unitPrice: unit,
          lineTotal: line,
          styleNotes: item.styleNotes,
          fabricInfo: item.fabricInfo,
          measurementSnapshot: snapshot,
        });
      }

      const discount = new Decimal(data.discount ?? 0);
      const totalAmount = Decimal.max(subtotal.sub(discount), new Decimal(0));
      const orderNumber = await this.nextOrderNumber(shopId, tx);

      const order = await tx.stitchingOrder.create({
        data: {
          shopId,
          customerId: data.customerId,
          orderNumber,
          status: OrderStatus.NEW,
          trialDate: data.trialDate ? new Date(data.trialDate) : undefined,
          deliveryDate: data.deliveryDate
            ? new Date(data.deliveryDate)
            : undefined,
          subtotal,
          discount,
          totalAmount,
          amountPaid: new Decimal(0),
          balanceDue: totalAmount,
          notes: data.notes,
          assignedToId: data.assignedToId,
          createdById: userId,
          items: { create: itemRows },
          statusHistory: {
            create: {
              fromStatus: null,
              toStatus: OrderStatus.NEW,
              note: 'Order created',
              changedById: userId,
            },
          },
        },
        include: { items: true, customer: true },
      });

      const advance = new Decimal(data.advanceAmount ?? 0);
      if (advance.gt(0)) {
        await tx.payment.create({
          data: {
            shopId,
            orderId: order.id,
            customerId: data.customerId,
            amount: advance,
            kind: 'ADVANCE',
            method: (data.advanceMethod as never) || 'CASH',
            idempotencyKey: data.idempotencyKey
              ? `${data.idempotencyKey}:advance`
              : undefined,
            recordedById: userId,
          },
        });
        const amountPaid = advance;
        const balanceDue = Decimal.max(totalAmount.sub(amountPaid), new Decimal(0));
        return tx.stitchingOrder.update({
          where: { id: order.id },
          data: { amountPaid, balanceDue },
          include: { items: true, customer: true, payments: true },
        });
      }

      return order;
    });
  }

  async list(query: {
    status?: OrderStatus;
    customerId?: string;
    from?: string;
    to?: string;
    overdue?: boolean;
    page?: number;
    pageSize?: number;
  }) {
    const shopId = this.shopId();
    const page = Math.max(1, query.page ?? 1);
    const pageSize = Math.min(100, Math.max(1, query.pageSize ?? 20));
    const now = new Date();
    const where: Prisma.StitchingOrderWhereInput = {
      shopId,
      ...(query.status ? { status: query.status } : {}),
      ...(query.customerId ? { customerId: query.customerId } : {}),
      ...(query.from || query.to
        ? {
            deliveryDate: {
              ...(query.from ? { gte: new Date(query.from) } : {}),
              ...(query.to ? { lte: new Date(query.to) } : {}),
            },
          }
        : {}),
      ...(query.overdue
        ? {
            deliveryDate: { lt: now },
            status: { notIn: [OrderStatus.DELIVERED, OrderStatus.CANCELLED] },
          }
        : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.stitchingOrder.findMany({
        where,
        orderBy: [{ deliveryDate: 'asc' }, { createdAt: 'desc' }],
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          customer: { select: { id: true, fullName: true, phone: true } },
          items: true,
        },
      }),
      this.prisma.stitchingOrder.count({ where }),
    ]);
    return { items, total, page, pageSize };
  }

  async get(id: string) {
    const shopId = this.shopId();
    const order = await this.prisma.stitchingOrder.findFirst({
      where: { id, shopId },
      include: {
        customer: true,
        items: true,
        payments: { orderBy: { createdAt: 'desc' } },
        statusHistory: { orderBy: { createdAt: 'asc' } },
        shop: {
          select: {
            id: true,
            name: true,
            phone: true,
            address: true,
            addressLine1: true,
            addressLine2: true,
            city: true,
            state: true,
            pincode: true,
            settings: {
              select: {
                receiptHeader: true,
                receiptFooter: true,
                receiptContact: true,
                taxEnabled: true,
                taxPercent: true,
                taxId: true,
              },
            },
          },
        },
      },
    });
    if (!order) {
      throw new NotFoundException({
        code: 'ORDER_NOT_FOUND',
        message: 'Order not found',
      });
    }
    return order;
  }

  async attachMeasurement(
    orderId: string,
    itemId: string,
    measurementRecordId: string,
  ) {
    const shopId = this.shopId();
    const order = await this.prisma.stitchingOrder.findFirst({
      where: { id: orderId, shopId },
      include: { items: true },
    });
    if (!order) {
      throw new NotFoundException({
        code: 'ORDER_NOT_FOUND',
        message: 'Order not found',
      });
    }
    const item = order.items.find((i) => i.id === itemId);
    if (!item) {
      throw new NotFoundException({
        code: 'ORDER_ITEM_NOT_FOUND',
        message: 'Order item not found',
      });
    }
    const m = await this.prisma.measurementRecord.findFirst({
      where: {
        id: measurementRecordId,
        shopId,
        customerId: order.customerId,
      },
      include: { garmentTemplate: true },
    });
    if (!m) {
      throw new NotFoundException({
        code: 'MEASUREMENT_NOT_FOUND',
        message: 'Measurement not found for this customer',
      });
    }

    const snapshot = {
      measurementRecordId: m.id,
      version: m.version,
      unit: m.unit,
      values: m.values,
      template: {
        id: m.garmentTemplate.id,
        name: m.garmentTemplate.name,
        code: m.garmentTemplate.code,
        version: m.garmentTemplate.version,
        fields: m.garmentTemplate.fields,
      },
      capturedAt: new Date().toISOString(),
    };

    await this.prisma.orderItem.update({
      where: { id: itemId },
      data: {
        measurementSnapshot: snapshot,
        garmentTemplateId: item.garmentTemplateId ?? m.garmentTemplateId,
      },
    });

    return this.get(orderId);
  }

  async transition(id: string, userId: string, toStatus: OrderStatus, note?: string) {
    const order = await this.get(id);
    if (!canTransition(order.status, toStatus)) {
      throw new BadRequestException({
        code: 'INVALID_STATUS_TRANSITION',
        message: `Cannot transition from ${order.status} to ${toStatus}`,
        params: { from: order.status, to: toStatus },
      });
    }
    return this.prisma.$transaction(async (tx) => {
      await tx.orderStatusHistory.create({
        data: {
          orderId: id,
          fromStatus: order.status,
          toStatus,
          note,
          changedById: userId,
        },
      });
      return tx.stitchingOrder.update({
        where: { id },
        data: {
          status: toStatus,
          deliveredAt: toStatus === OrderStatus.DELIVERED ? new Date() : undefined,
          cancelledAt: toStatus === OrderStatus.CANCELLED ? new Date() : undefined,
        },
        include: { statusHistory: true, items: true },
      });
    });
  }

  async calendar(from: string, to: string) {
    const shopId = this.shopId();
    const fromDate = new Date(from);
    const toDate = new Date(to);
    const orders = await this.prisma.stitchingOrder.findMany({
      where: {
        shopId,
        OR: [
          { deliveryDate: { gte: fromDate, lte: toDate } },
          { trialDate: { gte: fromDate, lte: toDate } },
        ],
        status: { not: OrderStatus.CANCELLED },
      },
      include: {
        customer: { select: { id: true, fullName: true, phone: true } },
      },
      orderBy: { deliveryDate: 'asc' },
    });

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);

    const summary = {
      todayDeliveries: orders.filter(
        (o) =>
          o.deliveryDate &&
          o.deliveryDate >= todayStart &&
          o.deliveryDate <= todayEnd &&
          o.status !== OrderStatus.DELIVERED,
      ).length,
      overdue: await this.prisma.stitchingOrder.count({
        where: {
          shopId,
          deliveryDate: { lt: todayStart },
          status: { notIn: [OrderStatus.DELIVERED, OrderStatus.CANCELLED] },
        },
      }),
      byStatus: await this.prisma.stitchingOrder.groupBy({
        by: ['status'],
        where: { shopId, status: { not: OrderStatus.CANCELLED } },
        _count: true,
      }),
    };

    return { orders, summary };
  }
}
