import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { requireShopContext } from '../../common/tenant/tenant-context';

export type TemplateField = {
  id: string;
  name: string;
  type: 'number' | 'text' | 'select';
  unit?: string;
  required?: boolean;
  order?: number;
  helpText?: string;
  defaultValue?: string | number;
  validation?: { min?: number; max?: number };
};

function slugId(raw: string) {
  return raw
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 48);
}

function validateFields(fields: unknown): TemplateField[] {
  if (!Array.isArray(fields) || fields.length === 0) {
    throw new BadRequestException({
      code: 'INVALID_TEMPLATE_FIELDS',
      message: 'Add at least one measurement field',
    });
  }
  return fields.map((f, i) => {
    const raw = (f ?? {}) as Record<string, unknown>;
    const id = String(raw.id ?? raw.key ?? '').trim();
    const name = String(raw.name ?? raw.label ?? '').trim();
    const typeRaw = String(raw.type ?? 'number').trim().toLowerCase();
    const type =
      typeRaw === 'text' || typeRaw === 'select' || typeRaw === 'number'
        ? (typeRaw as TemplateField['type'])
        : 'number';

    if (!id || !name) {
      throw new BadRequestException({
        code: 'INVALID_TEMPLATE_FIELDS',
        message: `Measurement field ${i + 1} needs a name`,
      });
    }

    const field: TemplateField = {
      id: slugId(id) || `field_${i + 1}`,
      name,
      type,
      unit: raw.unit != null ? String(raw.unit) : 'inch',
      required: Boolean(raw.required),
      order: typeof raw.order === 'number' ? raw.order : i + 1,
    };
    if (raw.helpText != null) field.helpText = String(raw.helpText);
    return field;
  });
}

@Injectable()
export class GarmentTemplatesService {
  constructor(private readonly prisma: PrismaService) {}

  private shopId() {
    return requireShopContext().shopId;
  }

  async create(data: {
    name: string;
    code: string;
    description?: string;
    fields: unknown;
  }) {
    const fields = validateFields(data.fields);
    const code = data.code.toLowerCase().trim();
    const existing = await this.prisma.garmentTemplate.findFirst({
      where: { shopId: this.shopId(), code },
    });
    if (existing) {
      throw new BadRequestException({
        code: 'TEMPLATE_CODE_EXISTS',
        message: 'A template with this code already exists',
      });
    }
    return this.prisma.garmentTemplate.create({
      data: {
        shopId: this.shopId(),
        name: data.name.trim(),
        code,
        description: data.description,
        fields,
      },
    });
  }

  list(activeOnly = true) {
    return this.prisma.garmentTemplate.findMany({
      where: {
        shopId: this.shopId(),
        ...(activeOnly ? { isActive: true } : {}),
      },
      orderBy: { name: 'asc' },
    });
  }

  async get(id: string) {
    const t = await this.prisma.garmentTemplate.findFirst({
      where: { id, shopId: this.shopId() },
    });
    if (!t) {
      throw new NotFoundException({
        code: 'TEMPLATE_NOT_FOUND',
        message: 'Template not found',
      });
    }
    return t;
  }

  async update(
    id: string,
    data: Partial<{
      name: string;
      description: string;
      fields: unknown;
      isActive: boolean;
    }>,
  ) {
    const current = await this.get(id);
    const fields = data.fields ? validateFields(data.fields) : undefined;
    return this.prisma.garmentTemplate.update({
      where: { id },
      data: {
        name: data.name,
        description: data.description,
        isActive: data.isActive,
        fields,
        version: fields ? current.version + 1 : current.version,
      },
    });
  }
}
