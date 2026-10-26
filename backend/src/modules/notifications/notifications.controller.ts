import {
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ShopRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get()
  list(@CurrentUser() user: { userId: string; shopId?: string }) {
    return this.notifications.list(user.userId, user.shopId);
  }

  @Post('read-all')
  readAll(@CurrentUser() user: { userId: string }) {
    return this.notifications.markAllRead(user.userId);
  }

  /** Manual trigger for testing delivery reminders (OWNER/MANAGER). */
  @Post('run-delivery-reminders')
  @UseGuards(RolesGuard)
  @Roles(ShopRole.OWNER, ShopRole.MANAGER)
  runDeliveryReminders() {
    return this.notifications.createDeliveryReminders();
  }

  @Post(':id/read')
  read(@CurrentUser() user: { userId: string }, @Param('id') id: string) {
    return this.notifications.markRead(user.userId, id);
  }
}
