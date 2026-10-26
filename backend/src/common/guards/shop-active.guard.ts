import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

/** Blocks shop-scoped operations when the active shop is suspended. */
@Injectable()
export class ShopActiveGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<{
      user?: { shopId?: string; shopStatus?: string };
    }>();
    const user = req.user;
    if (user?.shopId && user.shopStatus === 'SUSPENDED') {
      throw new ForbiddenException({
        code: 'SHOP_SUSPENDED',
        message: 'This shop is suspended. Contact support.',
      });
    }
    return true;
  }
}
