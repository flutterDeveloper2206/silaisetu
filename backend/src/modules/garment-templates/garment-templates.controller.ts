import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { IsArray, IsBoolean, IsOptional, IsString, MinLength } from 'class-validator';
import { ShopRole } from '@prisma/client';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { GarmentTemplatesService } from './garment-templates.service';

class TemplateDto {
  @IsString() @MinLength(2) name!: string;
  @IsString() @MinLength(2) code!: string;
  @IsOptional() @IsString() description?: string;
  @IsArray() fields!: unknown[];
}

@ApiTags('garment-templates')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
@Controller('garment-templates')
export class GarmentTemplatesController {
  constructor(private readonly service: GarmentTemplatesService) {}

  @Post()
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  create(@Body() dto: TemplateDto) {
    return this.service.create(dto);
  }

  @Get()
  list(@Query('all') all?: string) {
    return this.service.list(all !== 'true');
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.service.get(id);
  }

  @Patch(':id')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  update(
    @Param('id') id: string,
    @Body()
    dto: Partial<TemplateDto> & { isActive?: boolean },
  ) {
    return this.service.update(id, dto);
  }
}
