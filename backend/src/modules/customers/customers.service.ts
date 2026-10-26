import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';

@Injectable()
export class CustomersService {
  constructor(private readonly prisma: PrismaService) {}

  private shopId() {
    return requireShopContext().shopId;
  }

  async create(
    userId: string,
    data: {
      fullName: string;
      phone: string;
      altPhone?: string;
      email?: string;
      address?: string;
      notes?: string;
    },
  ) {
    const shopId = this.shopId();
    return this.prisma.customer.create({
      data: { ...data, shopId, createdById: userId },
    });
  }

  async list(query: {
    search?: string;
    archived?: boolean;
    page?: number;
    pageSize?: number;
  }) {
    const shopId = this.shopId();
    const page = Math.max(1, query.page ?? 1);
    const pageSize = Math.min(100, Math.max(1, query.pageSize ?? 20));
    const where: Prisma.CustomerWhereInput = {
      shopId,
      isArchived: query.archived ?? false,
      ...(query.search
        ? {
            OR: [
              { fullName: { contains: query.search, mode: 'insensitive' } },
              { phone: { contains: query.search } },
              { email: { contains: query.search, mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.customer.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.customer.count({ where }),
    ]);
    return { items, total, page, pageSize };
  }

  async get(id: string) {
    const shopId = this.shopId();
    const customer = await this.prisma.customer.findFirst({
      where: { id, shopId },
      include: {
        orders: {
          orderBy: { createdAt: 'desc' },
          take: 20,
          select: {
            id: true,
            orderNumber: true,
            status: true,
            totalAmount: true,
            balanceDue: true,
            deliveryDate: true,
            createdAt: true,
          },
        },
        measurements: {
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
        payments: {
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
      },
    });
    if (!customer) {
      throw new NotFoundException({
        code: 'CUSTOMER_NOT_FOUND',
        message: 'Customer not found',
      });
    }
    const outstanding = await this.prisma.stitchingOrder.aggregate({
      where: { shopId, customerId: id, balanceDue: { gt: 0 } },
      _sum: { balanceDue: true },
    });
    return {
      ...customer,
      outstandingBalance: outstanding._sum.balanceDue ?? 0,
    };
  }

  async update(
    id: string,
    data: Partial<{
      fullName: string;
      phone: string;
      altPhone: string;
      email: string;
      address: string;
      notes: string;
    }>,
  ) {
    await this.get(id);
    return this.prisma.customer.update({ where: { id }, data });
  }

  async archive(id: string, archived = true) {
    await this.get(id);
    return this.prisma.customer.update({
      where: { id },
      data: { isArchived: archived },
    });
  }

  /** Cross-tenant probe helper for tests */
  async unsafeGetByIdOnly(id: string) {
    return this.prisma.customer.findUnique({ where: { id } });
  }

  assertOwned(customerShopId: string) {
    if (customerShopId !== this.shopId()) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'Cross-tenant access denied',
      });
    }
  }
}
