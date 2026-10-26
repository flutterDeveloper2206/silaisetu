import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ShopRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';

@Injectable()
export class StaffService {
  constructor(private readonly prisma: PrismaService) {}

  list() {
    const shopId = requireShopContext().shopId;
    return this.prisma.shopMembership.findMany({
      where: { shopId },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            isActive: true,
          },
        },
        _count: { select: { assignedOrders: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async invite(data: {
    email: string;
    fullName: string;
    password: string;
    role: ShopRole;
    phone?: string;
  }) {
    const shopId = requireShopContext().shopId;
    if (data.role === ShopRole.OWNER) {
      throw new ConflictException({
        code: 'INVALID_ROLE',
        message: 'Cannot invite another OWNER via this endpoint',
      });
    }

    let user = await this.prisma.user.findUnique({
      where: { email: data.email.toLowerCase() },
    });
    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: data.email.toLowerCase(),
          fullName: data.fullName,
          phone: data.phone,
          passwordHash: await bcrypt.hash(data.password, 12),
          emailVerifiedAt: new Date(),
        },
      });
    }

    const existing = await this.prisma.shopMembership.findUnique({
      where: { shopId_userId: { shopId, userId: user.id } },
    });
    if (existing?.isActive) {
      throw new ConflictException({
        code: 'ALREADY_MEMBER',
        message: 'User is already a member',
      });
    }

    return this.prisma.shopMembership.upsert({
      where: { shopId_userId: { shopId, userId: user.id } },
      create: {
        shopId,
        userId: user.id,
        role: data.role,
        isActive: true,
        joinedAt: new Date(),
      },
      update: {
        role: data.role,
        isActive: true,
        joinedAt: new Date(),
      },
      include: {
        user: { select: { id: true, fullName: true, email: true } },
      },
    });
  }

  async updateRole(membershipId: string, role: ShopRole) {
    const shopId = requireShopContext().shopId;
    const m = await this.prisma.shopMembership.findFirst({
      where: { id: membershipId, shopId },
    });
    if (!m) {
      throw new NotFoundException({
        code: 'MEMBERSHIP_NOT_FOUND',
        message: 'Membership not found',
      });
    }
    return this.prisma.shopMembership.update({
      where: { id: membershipId },
      data: { role },
    });
  }

  async deactivate(membershipId: string) {
    const shopId = requireShopContext().shopId;
    const m = await this.prisma.shopMembership.findFirst({
      where: { id: membershipId, shopId },
    });
    if (!m) {
      throw new NotFoundException({
        code: 'MEMBERSHIP_NOT_FOUND',
        message: 'Membership not found',
      });
    }
    if (m.role === ShopRole.OWNER) {
      throw new ConflictException({
        code: 'CANNOT_DEACTIVATE_OWNER',
        message: 'Cannot deactivate shop owner',
      });
    }
    return this.prisma.shopMembership.update({
      where: { id: membershipId },
      data: { isActive: false },
    });
  }
}
