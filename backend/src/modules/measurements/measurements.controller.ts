import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsObject, IsOptional, IsString, IsUUID } from 'class-validator';
import { MeasurementUnit, ShopRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { MeasurementsService } from './measurements.service';

class CreateMeasurementDto {
  @IsUUID() customerId!: string;
  @IsUUID() garmentTemplateId!: string;
  @IsEnum(MeasurementUnit) unit!: MeasurementUnit;
  @IsObject() values!: Record<string, unknown>;
  @IsOptional() @IsString() notes?: string;
}

@ApiTags('measurements')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
@Controller('measurements')
export class MeasurementsController {
  constructor(private readonly service: MeasurementsService) {}

  @Post()
  create(
    @CurrentUser() user: { userId: string },
    @Body() dto: CreateMeasurementDto,
  ) {
    return this.service.create(user.userId, dto);
  }

  @Get()
  list(
    @Query('customerId') customerId: string,
    @Query('garmentTemplateId') garmentTemplateId?: string,
  ) {
    return this.service.list(customerId, garmentTemplateId);
  }

  @Get('compare')
  compare(
    @Query('customerId') customerId: string,
    @Query('garmentTemplateId') garmentTemplateId: string,
  ) {
    return this.service.compare(customerId, garmentTemplateId);
  }
}
