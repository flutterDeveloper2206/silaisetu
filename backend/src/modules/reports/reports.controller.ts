import { Controller, Get, Header, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { ShopRole } from '@prisma/client';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { ReportsService } from './reports.service';

@ApiTags('reports')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}

  @Get('summary')
  summary(@Query('from') from?: string, @Query('to') to?: string) {
    return this.reports.summary(from, to);
  }

  @Get('orders.csv')
  @Header('Content-Type', 'text/csv')
  csv(@Query('from') from?: string, @Query('to') to?: string) {
    return this.reports.csvOrders(from, to);
  }
}
