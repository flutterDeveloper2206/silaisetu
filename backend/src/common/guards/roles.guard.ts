import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ShopRole } from '@prisma/client';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.getAllAndOverride<ShopRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!roles?.length) return true;

    const req = context.switchToHttp().getRequest<{
      user?: {
        shopId?: string;
        shopRole?: ShopRole;
        shopStatus?: string;
      };
    }>();
    const user = req.user;
    if (!user?.shopId || !user.shopRole) {
      throw new ForbiddenException({
        code: 'SHOP_CONTEXT_REQUIRED',
        message: 'Authorized shop context required',
      });
    }
    if (user.shopStatus === 'SUSPENDED') {
      throw new ForbiddenException({
        code: 'SHOP_SUSPENDED',
        message: 'Shop is suspended',
      });
    }
    if (!roles.includes(user.shopRole)) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'Insufficient shop permissions',
      });
    }
    return true;
  }
}
