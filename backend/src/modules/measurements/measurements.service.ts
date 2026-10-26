import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { MeasurementUnit, Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';
import { TemplateField } from '../garment-templates/garment-templates.service';

@Injectable()
export class MeasurementsService {
  constructor(private readonly prisma: PrismaService) {}

  private shopId() {
    return requireShopContext().shopId;
  }

  private validateValues(fields: TemplateField[], values: Record<string, unknown>) {
    const filled = Object.entries(values).filter(
      ([, v]) => v !== undefined && v !== null && `${v}`.trim() !== '',
    );
    if (filled.length === 0) {
      throw new BadRequestException({
        code: 'MEASUREMENT_VALIDATION',
        message: 'Enter at least one measurement component',
      });
    }

    // Validate types for known template fields; allow extra custom POM keys.
    const byId = new Map(fields.map((f) => [f.id, f]));
    for (const [key, v] of Object.entries(values)) {
      if (v === undefined || v === null || `${v}`.trim() === '') continue;
      const field = byId.get(key);
      if (!field || field.type !== 'number') continue;
      const num = Number(v);
      if (Number.isNaN(num)) {
        throw new BadRequestException({
          code: 'MEASUREMENT_VALIDATION',
          message: `${field.name} must be a number`,
        });
      }
      if (field.validation?.min !== undefined && num < field.validation.min) {
        throw new BadRequestException({
          code: 'MEASUREMENT_VALIDATION',
          message: `${field.name} below minimum`,
        });
      }
      if (field.validation?.max !== undefined && num > field.validation.max) {
        throw new BadRequestException({
          code: 'MEASUREMENT_VALIDATION',
          message: `${field.name} above maximum`,
        });
      }
    }
  }

  async create(
    userId: string,
    data: {
      customerId: string;
      garmentTemplateId: string;
      unit: MeasurementUnit;
      values: Record<string, unknown>;
      notes?: string;
    },
  ) {
    const shopId = this.shopId();
    const customer = await this.prisma.customer.findFirst({
      where: { id: data.customerId, shopId },
    });
    if (!customer) {
      throw new NotFoundException({
        code: 'CUSTOMER_NOT_FOUND',
        message: 'Customer not found',
      });
    }
    const template = await this.prisma.garmentTemplate.findFirst({
      where: { id: data.garmentTemplateId, shopId },
    });
    if (!template) {
      throw new NotFoundException({
        code: 'TEMPLATE_NOT_FOUND',
        message: 'Template not found',
      });
    }
    const fields = template.fields as TemplateField[];
    this.validateValues(fields, data.values);

    const latest = await this.prisma.measurementRecord.findFirst({
      where: {
        shopId,
        customerId: data.customerId,
        garmentTemplateId: data.garmentTemplateId,
      },
      orderBy: { version: 'desc' },
    });

    return this.prisma.measurementRecord.create({
      data: {
        shopId,
        customerId: data.customerId,
        garmentTemplateId: data.garmentTemplateId,
        version: (latest?.version ?? 0) + 1,
        unit: data.unit,
        values: data.values as Prisma.InputJsonValue,
        notes: data.notes,
        createdById: userId,
      },
    });
  }

  list(customerId: string, garmentTemplateId?: string) {
    return this.prisma.measurementRecord.findMany({
      where: {
        shopId: this.shopId(),
        customerId,
        ...(garmentTemplateId ? { garmentTemplateId } : {}),
      },
      orderBy: [{ garmentTemplateId: 'asc' }, { version: 'desc' }],
      include: {
        garmentTemplate: { select: { id: true, name: true, code: true } },
      },
    });
  }

  async compare(customerId: string, garmentTemplateId: string) {
    const records = await this.prisma.measurementRecord.findMany({
      where: {
        shopId: this.shopId(),
        customerId,
        garmentTemplateId,
      },
      orderBy: { version: 'desc' },
      take: 2,
    });
    return {
      current: records[0] ?? null,
      previous: records[1] ?? null,
    };
  }
}
