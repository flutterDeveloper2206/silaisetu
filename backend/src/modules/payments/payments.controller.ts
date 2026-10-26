import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';
import { PaymentKind, PaymentMethod, ShopRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { PaymentsService } from './payments.service';

class RecordPaymentDto {
  @IsUUID() orderId!: string;
  @IsString() amount!: string;
  @IsEnum(PaymentKind) kind!: PaymentKind;
  @IsOptional() @IsEnum(PaymentMethod) method?: PaymentMethod;
  @IsOptional() @IsString() reference?: string;
  @IsOptional() @IsString() notes?: string;
  @IsOptional() @IsString() idempotencyKey?: string;
}

@ApiTags('payments')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Roles(ShopRole.OWNER, ShopRole.MANAGER)
@Controller('payments')
export class PaymentsController {
  constructor(private readonly payments: PaymentsService) {}

  @Post()
  record(
    @CurrentUser() user: { userId: string },
    @Body() dto: RecordPaymentDto,
  ) {
    return this.payments.record(user.userId, dto);
  }

  @Get('order/:orderId')
  list(@Param('orderId') orderId: string) {
    return this.payments.listByOrder(orderId);
  }

  @Get(':id/receipt')
  receipt(@Param('id') id: string) {
    return this.payments.receipt(id);
  }

  @Post(':id/reverse')
  @Roles(ShopRole.OWNER)
  reverse(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() body: { reason?: string },
  ) {
    return this.payments.reverse(user.userId, id, body.reason);
  }
}
