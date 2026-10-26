import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  LanguageCode,
  MeasurementUnit,
  ShopRole,
  ShopStatus,
} from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';

function slugify(name: string) {
  return (
    name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      .slice(0, 48) || 'shop'
  );
}

@Injectable()
export class TenantsService {
  constructor(private readonly prisma: PrismaService) {}

  async createShop(
    userId: string,
    data: {
      name: string;
      phone?: string;
      email?: string;
      address?: string;
      city?: string;
      state?: string;
      pincode?: string;
      defaultLanguage?: LanguageCode;
      measurementUnit?: MeasurementUnit;
      workingHours?: object;
    },
  ) {
    let slug = slugify(data.name);
    const exists = await this.prisma.shop.findUnique({ where: { slug } });
    if (exists) slug = `${slug}-${Date.now().toString(36)}`;

    return this.prisma.$transaction(async (tx) => {
      const shop = await tx.shop.create({
        data: {
          name: data.name,
          slug,
          phone: data.phone,
          email: data.email,
          address: data.address,
          city: data.city,
          state: data.state,
          pincode: data.pincode,
          defaultLanguage: data.defaultLanguage ?? LanguageCode.gu,
          measurementUnit: data.measurementUnit ?? MeasurementUnit.INCH,
          workingHours: data.workingHours ?? undefined,
          status: ShopStatus.ACTIVE,
          settings: { create: {} },
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
              fromStatus: null,
              toStatus: ShopStatus.ACTIVE,
              reason: 'Shop created',
              actorId: userId,
            },
          },
        },
        include: { settings: true, memberships: true },
      });

      // Seed default garment templates (GMM / class POM charts)
      const n = (
        id: string,
        name: string,
        order: number,
        required = false,
      ) => ({ id, name, type: 'number' as const, unit: 'INCH', required, order });

      const defaults = [
        {
          name: 'T-Shirt',
          code: 'tshirt',
          fields: [
            n('half_chest', '½ Chest', 1, true),
            n('body_length', 'Body Length', 2, true),
            n('half_waist', '½ Waist', 3),
            n('shoulder_length', 'Shoulder Length', 4, true),
            n('body_hem', 'Body Hem', 5),
            n('sleeve_length', 'Sleeve Length', 6, true),
            n('half_bicep', '½ Bicep', 7),
            n('sleeve_opening', 'Sleeve Opening', 8),
            n('neck_opening', 'Neck Opening', 9),
            n('front_neck_drop', 'Front Neck Drop', 10),
            n('back_neck_drop', 'Back Neck Drop', 11),
            n('front_neck_band_width', 'Front Neck Band Width', 12),
            n('side_seam_length', 'Side Seam Length', 13),
            n('sleeve_length_underarm', 'Sleeve Length (Under Arm)', 14),
            n('armhole', 'Arm Hole', 15),
            n('sleeve_hem_width', 'Sleeve Hem Width', 16),
            n('bottom_hem_width', 'Bottom Hem Width', 17),
            n('body_back_length', 'Body Back Length', 18),
          ],
        },
        {
          name: 'Polo',
          code: 'polo',
          fields: [
            n('body_length', 'Body Length', 1, true),
            n('half_chest', '½ Chest', 2, true),
            n('shoulder_length', 'Shoulder Length', 3, true),
            n('sleeve_length', 'Sleeve Length', 4, true),
            n('armhole_length', 'Arm Hole Length', 5),
            n('collar_length', 'Collar Length', 6),
            n('placket_length', 'Placket Length', 7),
            n('sleeve_opening', 'Sleeve Opening', 8),
          ],
        },
        {
          name: 'Shirt',
          code: 'shirt',
          fields: [
            n('half_chest', '½ Chest', 1, true),
            n('half_waist', '½ Waist', 2),
            n('body_hem_width', 'Body Hem Width', 3),
            n('shoulder_length_hps', 'Shoulder Length (From HPS)', 4, true),
            n('shoulder_seam', 'Shoulder Length (Seam to Seam)', 5),
            n('sleeve_length', 'Sleeve Length', 6, true),
            n('armhole_length', 'Arm Hole Length', 7),
            n('half_bicep', '½ Bicep', 8),
            n('sleeve_opening', 'Sleeve Opening', 9),
            n('armhole_curve', 'Arm Hole Length Along Curve', 10),
            n('high_chest_armhole', 'High Chest ½ Arm Hole', 11),
            n('high_back_armhole', 'High Back ½ Arm Hole', 12),
            n('front_neck_drop', 'Front Neck Drop', 13),
            n('body_length_hps', 'Body Length (From HPS)', 14, true),
            n('body_length_cb', 'Body Length (From C.B. Line)', 15),
            n('collar_length_outer', 'Collar Length Outer Edge', 16),
            n('collar_height', 'Collar Height (Center)', 17),
            n('collar_stand_length', 'Collar Stand Length', 18),
            n('collar_stand_height', 'Collar Stand Height', 19),
            n('collar_point', 'Collar Point', 20),
            n('yoke', 'Yoke (Across Back)', 21),
            n('cuff', 'Cuff', 22),
            n('neck', 'Neck / Collar', 23, true),
            n('pocket_width', 'Pocket Width', 24),
            n('pocket_depth', 'Pocket Depth', 25),
            n('placket_length', 'Placket Length', 26),
            // Legacy aliases for older clients
            n('chest', 'Chest', 27),
            n('shoulder', 'Shoulder', 28),
            n('sleeve', 'Sleeve', 29),
            n('length', 'Length', 30),
          ],
        },
        {
          name: 'Trouser',
          code: 'trouser',
          fields: [
            n('half_waist', '½ Waist', 1, true),
            n('hip', 'Hip', 2, true),
            n('half_thigh', '½ Thigh', 3),
            n('knee', 'Knee', 4),
            n('leg_opening', 'Leg Opening', 5),
            n('outseam_length', 'Length (Outseam)', 6, true),
            n('inseam', 'Inseam / Inside Leg', 7),
            n('front_rise', 'Front Rise', 8),
            n('back_rise', 'Back Rise', 9),
            n('waistband_depth', 'Waistband Depth', 10),
            n('waist', 'Waist', 11),
            n('length', 'Length', 12),
            n('thigh', 'Thigh', 13),
          ],
        },
        {
          name: 'Kurta',
          code: 'kurta',
          fields: [
            n('half_chest', '½ Chest', 1, true),
            n('shoulder_length', 'Shoulder Length', 2, true),
            n('body_length', 'Body Length', 3, true),
            n('sleeve_length', 'Sleeve Length', 4),
            n('half_waist', '½ Waist', 5),
            n('neck', 'Neck', 6),
            n('armhole', 'Arm Hole', 7),
            n('bottom_hem_width', 'Bottom Hem Width', 8),
          ],
        },
        {
          name: 'Blouse',
          code: 'blouse',
          fields: [
            n('bust', 'Bust', 1, true),
            n('half_waist', '½ Waist', 2),
            n('shoulder_length', 'Shoulder Length', 3, true),
            n('body_length', 'Body Length', 4, true),
            n('sleeve_length', 'Sleeve Length', 5),
            n('armhole', 'Arm Hole', 6),
            n('neck_opening', 'Neck Opening', 7),
            n('front_neck_drop', 'Front Neck Drop', 8),
            n('back_neck_drop', 'Back Neck Drop', 9),
          ],
        },
      ];

      for (const t of defaults) {
        await tx.garmentTemplate.create({
          data: {
            shopId: shop.id,
            name: t.name,
            code: t.code,
            fields: t.fields,
          },
        });
      }

      return shop;
    });
  }

  async myShops(userId: string) {
    return this.prisma.shopMembership.findMany({
      where: { userId, isActive: true },
      include: {
        shop: {
          select: {
            id: true,
            name: true,
            slug: true,
            status: true,
            phone: true,
            city: true,
            defaultLanguage: true,
            measurementUnit: true,
            createdAt: true,
          },
        },
      },
    });
  }

  async getShop(shopId: string, userId: string) {
    await this.assertMember(shopId, userId);
    const shop = await this.prisma.shop.findUnique({
      where: { id: shopId },
      include: { settings: true },
    });
    if (!shop) throw new NotFoundException({ code: 'SHOP_NOT_FOUND', message: 'Shop not found' });
    return shop;
  }

  async updateShop(
    shopId: string,
    userId: string,
    data: Partial<{
      name: string;
      phone: string;
      email: string;
      address: string;
      city: string;
      state: string;
      pincode: string;
      defaultLanguage: LanguageCode;
      measurementUnit: MeasurementUnit;
      workingHours: object;
      preferences: object;
    }>,
  ) {
    await this.assertMember(shopId, userId, [ShopRole.OWNER, ShopRole.MANAGER]);
    return this.prisma.shop.update({ where: { id: shopId }, data });
  }

  async getSettings(shopId: string, userId: string) {
    await this.assertMember(shopId, userId);
    return this.prisma.shopSettings.findUnique({ where: { shopId } });
  }

  async updateSettings(
    shopId: string,
    userId: string,
    data: {
      receiptFooter?: string;
      enableTrials?: boolean;
      defaultAdvancePct?: number;
      taxEnabled?: boolean;
      taxPercent?: number;
    },
  ) {
    await this.assertMember(shopId, userId, [ShopRole.OWNER, ShopRole.MANAGER]);
    return this.prisma.shopSettings.update({
      where: { shopId },
      data,
    });
  }

  private async assertMember(
    shopId: string,
    userId: string,
    roles?: ShopRole[],
  ) {
    const m = await this.prisma.shopMembership.findFirst({
      where: { shopId, userId, isActive: true },
    });
    if (!m) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'Not a member of this shop',
      });
    }
    if (roles && !roles.includes(m.role)) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'Insufficient permissions',
      });
    }
    return m;
  }

  requireActiveShop() {
    const ctx = requireShopContext();
    if (ctx.shopStatus === 'SUSPENDED') {
      throw new ForbiddenException({
        code: 'SHOP_SUSPENDED',
        message: 'Shop is suspended',
      });
    }
    return ctx;
  }
}
