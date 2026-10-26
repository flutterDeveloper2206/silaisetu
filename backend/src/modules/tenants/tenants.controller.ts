import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsObject,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';
import { LanguageCode, MeasurementUnit, ShopRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { TenantsService } from './tenants.service';

class CreateShopDto {
  @IsString()
  @MinLength(2)
  name!: string;

  @IsOptional() @IsString() phone?: string;
  @IsOptional() @IsEmail() email?: string;
  @IsOptional() @IsString() address?: string;
  @IsOptional() @IsString() city?: string;
  @IsOptional() @IsString() state?: string;
  @IsOptional() @IsString() pincode?: string;
  @IsOptional() @IsEnum(LanguageCode) defaultLanguage?: LanguageCode;
  @IsOptional() @IsEnum(MeasurementUnit) measurementUnit?: MeasurementUnit;
  @IsOptional() @IsObject() workingHours?: object;
}

class UpdateShopDto {
  @IsOptional() @IsString() name?: string;
  @IsOptional() @IsString() phone?: string;
  @IsOptional() @IsEmail() email?: string;
  @IsOptional() @IsString() address?: string;
  @IsOptional() @IsString() city?: string;
  @IsOptional() @IsString() state?: string;
  @IsOptional() @IsString() pincode?: string;
  @IsOptional() @IsEnum(LanguageCode) defaultLanguage?: LanguageCode;
  @IsOptional() @IsEnum(MeasurementUnit) measurementUnit?: MeasurementUnit;
  @IsOptional() @IsObject() workingHours?: object;
  @IsOptional() @IsObject() preferences?: object;
}

@ApiTags('shops')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('shops')
export class TenantsController {
  constructor(private readonly tenants: TenantsService) {}

  @Post()
  create(@CurrentUser() user: { userId: string }, @Body() dto: CreateShopDto) {
    return this.tenants.createShop(user.userId, dto);
  }

  @Get('mine')
  mine(@CurrentUser() user: { userId: string }) {
    return this.tenants.myShops(user.userId);
  }

  @Get(':id')
  get(@CurrentUser() user: { userId: string }, @Param('id') id: string) {
    return this.tenants.getShop(id, user.userId);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body() dto: UpdateShopDto,
  ) {
    return this.tenants.updateShop(id, user.userId, dto);
  }

  @Get(':id/settings')
  settings(@CurrentUser() user: { userId: string }, @Param('id') id: string) {
    return this.tenants.getSettings(id, user.userId);
  }

  @UseGuards(ShopActiveGuard, RolesGuard)
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  @Patch(':id/settings')
  updateSettings(
    @CurrentUser() user: { userId: string },
    @Param('id') id: string,
    @Body()
    dto: {
      receiptFooter?: string;
      enableTrials?: boolean;
      defaultAdvancePct?: number;
      taxEnabled?: boolean;
      taxPercent?: number;
    },
  ) {
    return this.tenants.updateSettings(id, user.userId, dto);
  }
}
