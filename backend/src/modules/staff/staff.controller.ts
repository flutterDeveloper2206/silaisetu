import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { IsEmail, IsEnum, IsOptional, IsString, MinLength } from 'class-validator';
import { ShopRole } from '@prisma/client';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { StaffService } from './staff.service';

class InviteDto {
  @IsEmail() email!: string;
  @IsString() @MinLength(2) fullName!: string;
  @IsString() @MinLength(8) password!: string;
  @IsEnum(ShopRole) role!: ShopRole;
  @IsOptional() @IsString() phone?: string;
}

@ApiTags('staff')
@ApiBearerAuth()
@ApiHeader({ name: 'X-Shop-Id', required: true })
@UseGuards(JwtAuthGuard, ShopActiveGuard, RolesGuard)
@Controller('staff')
export class StaffController {
  constructor(private readonly staff: StaffService) {}

  @Get()
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  list() {
    return this.staff.list();
  }

  @Post()
  @Roles(ShopRole.OWNER)
  invite(@Body() dto: InviteDto) {
    return this.staff.invite(dto);
  }

  @Patch(':id/role')
  @Roles(ShopRole.OWNER)
  role(@Param('id') id: string, @Body() body: { role: ShopRole }) {
    return this.staff.updateRole(id, body.role);
  }

  @Post(':id/deactivate')
  @Roles(ShopRole.OWNER)
  deactivate(@Param('id') id: string) {
    return this.staff.deactivate(id);
  }
}
