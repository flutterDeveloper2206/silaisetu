import {
  LanguageCode,
  MeasurementUnit,
  OrderStatus,
  PaymentKind,
  PaymentMethod,
  PrismaClient,
  ShopRole,
  ShopStatus,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const adminEmail =
    process.env.PLATFORM_ADMIN_EMAIL || 'admin@silaisetu.com';
  const adminPassword =
    process.env.PLATFORM_ADMIN_PASSWORD || 'SilaiSetu_Admin_2026!';
  const adminName = process.env.PLATFORM_ADMIN_NAME || 'Platform Admin';
  const ownerPassword =
    process.env.DEMO_OWNER_PASSWORD || 'SilaiSetu_Owner_2026!';

  const passwordHash = await bcrypt.hash(adminPassword, 12);
  const adminUser = await prisma.user.upsert({
    where: { email: adminEmail.toLowerCase() },
    update: {},
    create: {
      email: adminEmail.toLowerCase(),
      fullName: adminName,
      passwordHash,
      emailVerifiedAt: new Date(),
      languagePref: LanguageCode.en,
    },
  });

  await prisma.platformAdmin.upsert({
    where: { userId: adminUser.id },
    update: {},
    create: { userId: adminUser.id, isSuperAdmin: true },
  });

  async function seedShop(
    slug: string,
    name: string,
    ownerEmail: string,
    ownerName: string,
    ownerPhone: string,
  ) {
    const ownerHash = await bcrypt.hash(ownerPassword, 12);
    const owner = await prisma.user.upsert({
      where: { email: ownerEmail },
      update: {
        passwordHash: ownerHash,
        phone: ownerPhone,
        emailVerifiedAt: new Date(),
      },
      create: {
        email: ownerEmail,
        fullName: ownerName,
        passwordHash: ownerHash,
        phone: ownerPhone,
        emailVerifiedAt: new Date(),
        languagePref: LanguageCode.gu,
      },
    });

    const shop = await prisma.shop.upsert({
      where: { slug },
      update: { subscriptionLifetimeFree: true },
      create: {
        name,
        slug,
        phone: '07912345678',
        city: 'Ahmedabad',
        state: 'Gujarat',
        status: ShopStatus.ACTIVE,
        defaultLanguage: LanguageCode.gu,
        measurementUnit: MeasurementUnit.INCH,
        subscriptionLifetimeFree: true,
        settings: { create: { receiptFooter: 'Thank you — SilaiSetu' } },
        memberships: {
          create: {
            userId: owner.id,
            role: ShopRole.OWNER,
            isActive: true,
            joinedAt: new Date(),
          },
        },
        statusHistory: {
          create: {
            toStatus: ShopStatus.ACTIVE,
            reason: 'Seeded shop',
            actorId: adminUser.id,
          },
        },
      },
    });

    const shirt = await prisma.garmentTemplate.upsert({
      where: { shopId_code: { shopId: shop.id, code: 'shirt' } },
      update: {},
      create: {
        shopId: shop.id,
        name: 'Shirt',
        code: 'shirt',
        fields: [
          { id: 'chest', name: 'Chest', type: 'number', unit: 'INCH', required: true, order: 1 },
          { id: 'shoulder', name: 'Shoulder', type: 'number', unit: 'INCH', required: true, order: 2 },
          { id: 'sleeve', name: 'Sleeve', type: 'number', unit: 'INCH', required: true, order: 3 },
          { id: 'length', name: 'Length', type: 'number', unit: 'INCH', required: true, order: 4 },
        ],
      },
    });

    const orderNumber = `SS-SEED-${slug.toUpperCase()}-00001`;
    const existingOrder = await prisma.stitchingOrder.findFirst({
      where: { shopId: shop.id, orderNumber },
      include: { customer: true },
    });
    if (existingOrder) {
      return { shop, owner, customer: existingOrder.customer, order: existingOrder };
    }

    const customer =
      (await prisma.customer.findFirst({
        where: { shopId: shop.id, phone: '9988776655' },
      })) ||
      (await prisma.customer.create({
        data: {
          shopId: shop.id,
          fullName: 'Ramesh Patel',
          phone: '9988776655',
          address: 'Navrangpura',
          createdById: owner.id,
        },
      }));

    const measurement = await prisma.measurementRecord.create({
      data: {
        shopId: shop.id,
        customerId: customer.id,
        garmentTemplateId: shirt.id,
        version: 1,
        unit: MeasurementUnit.INCH,
        values: { chest: 40, shoulder: 17, sleeve: 24, length: 28 },
        createdById: owner.id,
      },
    });

    const order = await prisma.stitchingOrder.create({
      data: {
        shopId: shop.id,
        customerId: customer.id,
        orderNumber,
        status: OrderStatus.STITCHING,
        deliveryDate: new Date(Date.now() + 5 * 86400000),
        subtotal: 1500,
        discount: 0,
        totalAmount: 1500,
        amountPaid: 500,
        balanceDue: 1000,
        createdById: owner.id,
        items: {
          create: {
            garmentTemplateId: shirt.id,
            garmentName: 'Shirt',
            quantity: 1,
            unitPrice: 1500,
            lineTotal: 1500,
            measurementSnapshot: {
              measurementRecordId: measurement.id,
              version: 1,
              unit: 'INCH',
              values: measurement.values,
              template: {
                id: shirt.id,
                name: shirt.name,
                code: shirt.code,
                fields: shirt.fields,
              },
            },
          },
        },
        statusHistory: {
          create: [
            { toStatus: OrderStatus.NEW, changedById: owner.id },
            {
              fromStatus: OrderStatus.NEW,
              toStatus: OrderStatus.CUTTING,
              changedById: owner.id,
            },
            {
              fromStatus: OrderStatus.CUTTING,
              toStatus: OrderStatus.STITCHING,
              changedById: owner.id,
            },
          ],
        },
        payments: {
          create: {
            shopId: shop.id,
            customerId: customer.id,
            amount: 500,
            kind: PaymentKind.ADVANCE,
            method: PaymentMethod.UPI,
            recordedById: owner.id,
            idempotencyKey: `seed-advance-${slug}`,
          },
        },
      },
    });

    return { shop, owner, customer, order };
  }

  await seedShop(
    'demo-ahmedabad',
    'Demo Tailors Ahmedabad',
    process.env.DEMO_OWNER1_EMAIL || 'owner@silaisetu.com',
    'Kiran Shah',
    '9876543210',
  );
  await seedShop(
    'demo-surat',
    'Demo Boutique Surat',
    process.env.DEMO_OWNER2_EMAIL || 'owner2@silaisetu.com',
    'Meera Desai',
    '9876543211',
  );

  await prisma.platformSettings.upsert({
    where: { key: 'support_email' },
    update: { value: { email: 'support@silaisetu.local' } },
    create: {
      key: 'support_email',
      value: { email: 'support@silaisetu.local' },
    },
  });

  const subscriptionDefaults: Array<{ key: string; value: object }> = [
    { key: 'subscription.enabled', value: { v: false } },
    { key: 'subscription.trialDays', value: { v: 30 } },
    { key: 'subscription.paidDays', value: { v: 365 } },
    { key: 'subscription.amountInr', value: { v: 2999 } },
    { key: 'subscription.upiId', value: { v: '' } },
    { key: 'subscription.qrImageUrl', value: { v: '' } },
    {
      key: 'subscription.instructions',
      value: {
        v: 'Pay via UPI using the QR code, then upload the payment screenshot and enter the UPI transaction ID.',
      },
    },
  ];
  for (const row of subscriptionDefaults) {
    await prisma.platformSettings.upsert({
      where: { key: row.key },
      update: {},
      create: row,
    });
  }

  // eslint-disable-next-line no-console
  console.log('Seed complete');
  // eslint-disable-next-line no-console
  console.log(`Platform admin: ${adminEmail} / ${adminPassword}`);
  // eslint-disable-next-line no-console
  console.log(
    `Demo owners: ${process.env.DEMO_OWNER1_EMAIL || 'owner@silaisetu.com'} / ${ownerPassword}`,
  );
  // eslint-disable-next-line no-console
  console.log(
    `             ${process.env.DEMO_OWNER2_EMAIL || 'owner2@silaisetu.com'} / ${ownerPassword}`,
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
