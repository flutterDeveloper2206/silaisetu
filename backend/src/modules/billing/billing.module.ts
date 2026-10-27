import { Global, Module } from '@nestjs/common';
import { ShopActiveGuard } from '../../common/guards/shop-active.guard';
import { BillingController } from './billing.controller';
import { SubscriptionService } from './subscription.service';

@Global()
@Module({
  controllers: [BillingController],
  providers: [SubscriptionService, ShopActiveGuard],
  exports: [SubscriptionService, ShopActiveGuard],
})
export class BillingModule {}
