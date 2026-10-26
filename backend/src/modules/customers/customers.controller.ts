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
import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';
import { ShopRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { CustomersService } from './customers.service';

class CustomerDto {
  @IsString() @MinLength(2) fullName!: string;
  @IsString() @MinLength(8) phone!: string;
  @IsOptional() @IsString() altPhone?: string;
  @IsOptional() @IsEmail() email?: string;
  @IsOptional() @IsString() address?: string;
  @IsOptional() @IsString() notes?: string;
}

@ApiTags('customers')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Roles(ShopRole.OWNER, ShopRole.MANAGER, ShopRole.TAILOR)
@Controller('customers')
export class CustomersController {
  constructor(private readonly customers: CustomersService) {}

  @Post()
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  create(@CurrentUser() user: { userId: string }, @Body() dto: CustomerDto) {
    return this.customers.create(user.userId, dto);
  }

  @Get()
  list(
    @Query('search') search?: string,
    @Query('archived') archived?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.customers.list({
      search,
      archived: archived === 'true',
      page: page ? Number(page) : 1,
      pageSize: pageSize ? Number(pageSize) : 20,
    });
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.customers.get(id);
  }

  @Patch(':id')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  update(@Param('id') id: string, @Body() dto: Partial<CustomerDto>) {
    return this.customers.update(id, dto);
  }

  @Post(':id/archive')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  archive(@Param('id') id: string) {
    return this.customers.archive(id, true);
  }

  @Post(':id/restore')
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  restore(@Param('id') id: string) {
    return this.customers.archive(id, false);
  }
}
