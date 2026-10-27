import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { SubscriptionService } from '../../modules/billing/subscription.service';

/** Blocks shop-scoped operations when suspended or subscription required. */
@Injectable()
export class ShopActiveGuard implements CanActivate {
  constructor(private readonly subscription: SubscriptionService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<{
      user?: { shopId?: string; shopStatus?: string };
      headers?: Record<string, string | string[] | undefined>;
    }>();
    const user = req.user;
    const headerShop = req.headers?.['x-shop-id'];
    const shopId =
      user?.shopId ||
      (typeof headerShop === 'string' ? headerShop : undefined);

    if (user?.shopId && user.shopStatus === 'SUSPENDED') {
      throw new ForbiddenException({
        code: 'SHOP_SUSPENDED',
        message: 'This shop is suspended. Contact support.',
      });
    }

    if (shopId) {
      await this.subscription.assertShopAllowed(shopId);
    }
    return true;
  }
}
