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
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsObject, IsOptional, IsString } from 'class-validator';
import { ShopStatus } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { PlatformAdminOnly } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { PlatformAdminGuard } from '../../common/guards/platform-admin.guard';
import { PlatformAdminService } from './platform-admin.service';

class StatusDto {
  @IsEnum(ShopStatus) status!: ShopStatus;
  @IsOptional() @IsString() reason?: string;
}

@ApiTags('platform-admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PlatformAdminGuard)
@PlatformAdminOnly()
@Controller('platform-admin')
export class PlatformAdminController {
  constructor(private readonly service: PlatformAdminService) {}

  @Get('dashboard')
  dashboard() {
    return this.service.dashboard();
  }

  @Get('shops')
  shops(
    @Query('search') search?: string,
    @Query('status') status?: ShopStatus,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.service.listShops({
      search,
      status,
      page: page ? Number(page) : 1,
      pageSize: pageSize ? Number(pageSize) : 20,
    });
  }

  @Get('shops/:id')
  shop(@Param('id') id: string) {
    return this.service.getShop(id);
  }

  @Patch('shops/:id/status')
  status(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() dto: StatusDto,
  ) {
    return this.service.changeShopStatus(
      user.userId,
      id,
      dto.status,
      dto.reason,
    );
  }

  @Get('users')
  users(
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.service.listUsers(
      page ? Number(page) : 1,
      pageSize ? Number(pageSize) : 20,
      search,
    );
  }

  @Get('audit-logs')
  auditLogs(@Query('page') page?: string, @Query('pageSize') pageSize?: string) {
    return this.service.auditLogs(
      page ? Number(page) : 1,
      pageSize ? Number(pageSize) : 50,
    );
  }

  @Get('settings')
  settings() {
    return this.service.getSettings();
  }

  @Post('settings')
  upsertSetting(
    @CurrentUser() user: { userId: string },
    @Body() body: { key: string; value: object },
  ) {
    return this.service.upsertSetting(user.userId, body.key, body.value);
  }

  @Get('system-health')
  health() {
    return this.service.health();
  }
}
