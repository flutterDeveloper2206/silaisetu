import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tenantStorage, TenantStore } from '../tenant/tenant-context';

@Injectable()
export class TenantContextInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<{
      user?: {
        sub?: string;
        email?: string;
        isPlatformAdmin?: boolean;
        shopId?: string;
        shopRole?: TenantStore['shopRole'];
        shopStatus?: string;
        userId?: string;
      };
    }>();

    const user = req.user;
    if (!user) {
      return next.handle();
    }

    const store: TenantStore = {
      userId: user.userId || user.sub || '',
      email: user.email || '',
      isPlatformAdmin: Boolean(user.isPlatformAdmin),
      shopId: user.shopId,
      shopRole: user.shopRole,
      shopStatus: user.shopStatus,
    };

    return new Observable((subscriber) => {
      tenantStorage.run(store, () => {
        next.handle().subscribe({
          next: (v) => subscriber.next(v),
          error: (e) => subscriber.error(e),
          complete: () => subscriber.complete(),
        });
      });
    });
  }
}
