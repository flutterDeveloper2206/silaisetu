import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Headers,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiBody, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { memoryStorage } from 'multer';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { SubscriptionService } from './subscription.service';

@ApiTags('billing')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('billing')
export class BillingController {
  constructor(private readonly subscription: SubscriptionService) {}

  @Get('subscription')
  status(
    @CurrentUser() user: { userId: string; shopId?: string },
    @Headers('x-shop-id') shopHeader?: string,
  ) {
    const shopId = shopHeader || user.shopId;
    if (!shopId) {
      throw new BadRequestException({
        code: 'SHOP_CONTEXT_REQUIRED',
        message: 'X-Shop-Id header required',
      });
    }
    return this.subscription.getStatusForShop(shopId, user.userId);
  }

  @Post('subscription/proof')
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      required: ['transactionId', 'screenshot'],
      properties: {
        transactionId: { type: 'string' },
        amountInr: { type: 'number' },
        note: { type: 'string' },
        screenshot: { type: 'string', format: 'binary' },
      },
    },
  })
  @UseInterceptors(
    FileInterceptor('screenshot', {
      storage: memoryStorage(),
      limits: { fileSize: 8 * 1024 * 1024 },
    }),
  )
  submitProof(
    @CurrentUser() user: { userId: string; shopId?: string },
    @Headers('x-shop-id') shopHeader: string | undefined,
    @UploadedFile() file: Express.Multer.File,
    @Body()
    body: { transactionId?: string; amountInr?: string; note?: string },
  ) {
    const shopId = shopHeader || user.shopId;
    if (!shopId) {
      throw new BadRequestException({
        code: 'SHOP_CONTEXT_REQUIRED',
        message: 'X-Shop-Id header required',
      });
    }
    if (!body.transactionId) {
      throw new BadRequestException({
        code: 'INVALID_TRANSACTION_ID',
        message: 'Transaction ID is required',
      });
    }
    return this.subscription.submitProof({
      shopId,
      userId: user.userId,
      transactionId: body.transactionId,
      amountInr: body.amountInr ? Number(body.amountInr) : undefined,
      note: body.note,
      file,
    });
  }
}
