import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiBody, ApiConsumes, ApiTags } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEnum,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
} from 'class-validator';
import { ShopStatus, SubscriptionProofStatus } from '@prisma/client';
import { memoryStorage } from 'multer';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { PlatformAdminOnly } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { PlatformAdminGuard } from '../../common/guards/platform-admin.guard';
import { SubscriptionService } from '../billing/subscription.service';
import { PlatformAdminService } from './platform-admin.service';

class StatusDto {
  @IsEnum(ShopStatus) status!: ShopStatus;
  @IsOptional() @IsString() reason?: string;
}

class ShopSubscriptionDto {
  @IsOptional() @IsBoolean() subscriptionLifetimeFree?: boolean;
  @IsOptional() @IsString() trialEndsAt?: string | null;
  @IsOptional() @IsString() subscriptionExpiresAt?: string | null;
}

class SubscriptionConfigDto {
  @IsOptional() @IsBoolean() enabled?: boolean;
  @IsOptional() @IsNumber() trialDays?: number;
  @IsOptional() @IsNumber() paidDays?: number;
  @IsOptional() @IsNumber() amountInr?: number;
  @IsOptional() @IsString() upiId?: string;
  @IsOptional() @IsString() qrImageUrl?: string;
  @IsOptional() @IsString() instructions?: string;
}

class ReviewDto {
  @IsOptional() @IsString() reviewNote?: string;
}

@ApiTags('platform-admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PlatformAdminGuard)
@PlatformAdminOnly()
@Controller('platform-admin')
export class PlatformAdminController {
  constructor(
    private readonly service: PlatformAdminService,
    private readonly subscription: SubscriptionService,
  ) {}

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

  @Get('subscription-config')
  subscriptionConfig() {
    return this.subscription.getConfig();
  }

  @Post('subscription-config')
  saveSubscriptionConfig(
    @CurrentUser() user: { userId: string },
    @Body() body: SubscriptionConfigDto,
  ) {
    return this.subscription.saveConfig(user.userId, body);
  }

  @Post('subscription-config/qr')
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      required: ['qr'],
      properties: { qr: { type: 'string', format: 'binary' } },
    },
  })
  @UseInterceptors(
    FileInterceptor('qr', {
      storage: memoryStorage(),
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  async uploadQr(
    @CurrentUser() user: { userId: string },
    @UploadedFile() file: Express.Multer.File,
  ) {
    const path = this.subscription.saveScreenshot(file);
    return this.subscription.saveConfig(user.userId, { qrImageUrl: path });
  }

  @Get('subscription-proofs')
  subscriptionProofs(
    @Query('status') status?: SubscriptionProofStatus,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.subscription.listProofs({
      status,
      page: page ? Number(page) : 1,
      pageSize: pageSize ? Number(pageSize) : 20,
    });
  }

  @Post('subscription-proofs/:id/approve')
  approveProof(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() body: ReviewDto,
  ) {
    return this.subscription.approveProof(user.userId, id, body.reviewNote);
  }

  @Post('subscription-proofs/:id/reject')
  rejectProof(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() body: ReviewDto,
  ) {
    return this.subscription.rejectProof(user.userId, id, body.reviewNote);
  }

  @Patch('shops/:id/subscription')
  shopSubscription(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() body: ShopSubscriptionDto,
  ) {
    return this.subscription.updateShopSubscription(user.userId, id, body);
  }
}
