import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_ERROR';
    let message = 'An unexpected error occurred';
    let params: Record<string, unknown> | undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const body = exception.getResponse();
      if (typeof body === 'string') {
        message = body;
        code = HttpStatus[status] ?? code;
      } else if (typeof body === 'object' && body) {
        const obj = body as Record<string, unknown>;
        code = (obj.code as string) || (obj.error as string) || code;
        if (Array.isArray(obj.message)) {
          message = obj.message.join('; ');
          code = 'VALIDATION_ERROR';
        } else if (typeof obj.message === 'string') {
          message = obj.message;
        }
        if (obj.params && typeof obj.params === 'object') {
          params = obj.params as Record<string, unknown>;
        }
      }
    } else if (exception instanceof Error) {
      const anyErr = exception as Error & { code?: string };
      if (anyErr.code === 'SHOP_CONTEXT_REQUIRED') {
        status = HttpStatus.BAD_REQUEST;
        code = 'SHOP_CONTEXT_REQUIRED';
        message = 'X-Shop-Id header with an authorized shop is required';
      } else if (anyErr.message === 'TENANT_CONTEXT_MISSING') {
        status = HttpStatus.UNAUTHORIZED;
        code = 'UNAUTHORIZED';
        message = 'Authentication required';
      } else {
        this.logger.error(exception.message);
      }
    }

    res.status(status).json({
      code,
      message,
      ...(params ? { params } : {}),
      statusCode: status,
    });
  }
}
