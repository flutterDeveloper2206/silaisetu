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
import {
  IsArray,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { OrderStatus, ShopRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { OrdersService } from './orders.service';

class OrderItemDto {
  @IsOptional() @IsUUID() garmentTemplateId?: string;
  @IsString() garmentName!: string;
  @Type(() => Number) @IsNumber() @Min(1) quantity!: number;
  @IsString() unitPrice!: string;
  @IsOptional() @IsString() styleNotes?: string;
  @IsOptional() @IsString() fabricInfo?: string;
  @IsOptional() @IsUUID() measurementRecordId?: string;
}

class CreateOrderDto {
  @IsUUID() customerId!: string;
  @IsArray() @ValidateNested({ each: true }) @Type(() => OrderItemDto)
  items!: OrderItemDto[];
  @IsOptional() @IsString() trialDate?: string;
  @IsOptional() @IsString() deliveryDate?: string;
  @IsOptional() @IsString() discount?: string;
  @IsOptional() @IsString() notes?: string;
  @IsOptional() @IsUUID() assignedToId?: string;
  @IsOptional() @IsString() advanceAmount?: string;
  @IsOptional() @IsString() advanceMethod?: string;
  @IsOptional() @IsString() idempotencyKey?: string;
}

class StatusDto {
  @IsEnum(OrderStatus) status!: OrderStatus;
  @IsOptional() @IsString() note?: string;
}

class AttachMeasurementDto {
  @IsUUID() measurementRecordId!: string;
}

@ApiTags('orders')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
@Controller()
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Post('orders')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
  create(@CurrentUser() user: { userId: string }, @Body() dto: CreateOrderDto) {
    return this.orders.create(user.userId, dto);
  }

  @Get('orders')
  list(
    @Query('status') status?: OrderStatus,
    @Query('customerId') customerId?: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('overdue') overdue?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.orders.list({
      status,
      customerId,
      from,
      to,
      overdue: overdue === 'true',
      page: page ? Number(page) : 1,
      pageSize: pageSize ? Number(pageSize) : 20,
    });
  }

  @Get('orders/:id')
  get(@Param('id') id: string) {
    return this.orders.get(id);
  }

  @Patch('orders/:id/status')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
  status(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() dto: StatusDto,
  ) {
    return this.orders.transition(id, user.userId, dto.status, dto.note);
  }

  @Post('orders/:orderId/items/:itemId/measurement')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
  attachMeasurement(
    @Param('orderId') orderId: string,
    @Param('itemId') itemId: string,
    @Body() dto: AttachMeasurementDto,
  ) {
    return this.orders.attachMeasurement(
      orderId,
      itemId,
      dto.measurementRecordId,
    );
  }

  @Get('calendar')
  calendar(@Query('from') from: string, @Query('to') to: string) {
    const start =
      from || new Date(new Date().setDate(1)).toISOString().slice(0, 10);
    const end =
      to ||
      new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0)
        .toISOString()
        .slice(0, 10);
    return this.orders.calendar(start, end);
  }
}
