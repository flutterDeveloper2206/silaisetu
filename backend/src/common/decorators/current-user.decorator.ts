import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { getTenantContext } from '../tenant/tenant-context';

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext) => {
    const als = getTenantContext();
    if (als?.userId) return als;
    const req = ctx.switchToHttp().getRequest<{
      user?: {
        sub?: string;
        email?: string;
        isPlatformAdmin?: boolean;
        shopId?: string;
        shopRole?: string;
        shopStatus?: string;
      };
    }>();
    const u = req.user;
    if (!u) return undefined;
    return {
      userId: u.sub,
      email: u.email,
      isPlatformAdmin: Boolean(u.isPlatformAdmin),
      shopId: u.shopId,
      shopRole: u.shopRole,
      shopStatus: u.shopStatus,
    };
  },
);
