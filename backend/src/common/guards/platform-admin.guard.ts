import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PLATFORM_ADMIN_KEY } from '../decorators/roles.decorator';

@Injectable()
export class PlatformAdminGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<boolean>(
      PLATFORM_ADMIN_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!required) return true;

    const req = context.switchToHttp().getRequest<{
      user?: { isPlatformAdmin?: boolean };
    }>();
    if (!req.user?.isPlatformAdmin) {
      throw new ForbiddenException({
        code: 'PLATFORM_ADMIN_REQUIRED',
        message: 'Platform administrator access required',
      });
    }
    return true;
  }
}
