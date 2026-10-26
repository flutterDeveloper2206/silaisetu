import {
  Body,
  Controller,
  Get,
  Patch,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { Request, Response } from 'express';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AuthService } from './auth.service';
import {
  ChangePasswordDto,
  CompleteOnboardingDto,
  ForgotIdentifierDto,
  ForgotPasswordDto,
  OnboardingDraftDto,
  RefreshDto,
  RegisterDto,
  ResetPasswordDto,
  UpdateProfileDto,
  VerifyOtpDto,
} from './dto/auth.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('login')
  async login(
    @Body() body: { identifier?: string; email?: string; password: string },
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.auth.loginFlexible(body);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Public()
  @Post('refresh')
  async refresh(
    @Body() dto: RefreshDto,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
  ) {
    const token =
      dto.refreshToken ||
      (req.cookies?.refreshToken as string | undefined) ||
      '';
    const result = await this.auth.refresh(token);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout(
    @Body() dto: RefreshDto,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
    @CurrentUser() user: { userId: string },
  ) {
    const token =
      dto.refreshToken ||
      (req.cookies?.refreshToken as string | undefined);
    await this.auth.logout(token, user?.userId);
    res.clearCookie('refreshToken');
    return { success: true };
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@CurrentUser() user: { userId: string }) {
    return this.auth.me(user.userId);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Patch('me')
  updateMe(
    @CurrentUser() user: { userId: string },
    @Body() dto: UpdateProfileDto,
  ) {
    return this.auth.updateProfile(user.userId, dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('change-password')
  changePassword(
    @CurrentUser() user: { userId: string },
    @Body() dto: ChangePasswordDto,
  ) {
    return this.auth.changePassword(user.userId, dto);
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @Post('forgot-password')
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.auth.forgotPassword(dto);
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @Post('reset-password')
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.auth.resetPassword(dto);
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @Post('forgot-identifier')
  forgotIdentifier(@Body() dto: ForgotIdentifierDto) {
    return this.auth.forgotIdentifier(dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('verify/request')
  requestVerify(
    @CurrentUser() user: { userId: string },
    @Body() body: { channel?: 'email' | 'phone' },
  ) {
    return this.auth.requestVerification(user.userId, body.channel);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('verify/confirm')
  confirmVerify(
    @CurrentUser() user: { userId: string },
    @Body() dto: VerifyOtpDto,
  ) {
    return this.auth.confirmVerification(user.userId, dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('onboarding')
  getOnboarding(@CurrentUser() user: { userId: string }) {
    return this.auth.getOnboardingDraft(user.userId);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('onboarding/draft')
  saveDraft(
    @CurrentUser() user: { userId: string },
    @Body() dto: OnboardingDraftDto,
  ) {
    return this.auth.saveOnboardingDraft(user.userId, dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('onboarding/complete')
  complete(
    @CurrentUser() user: { userId: string },
    @Body() dto: CompleteOnboardingDto,
  ) {
    return this.auth.completeOnboarding(user.userId, dto);
  }

  private setRefreshCookie(res: Response, refreshToken: string) {
    res.cookie('refreshToken', refreshToken, {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.COOKIE_SECURE === 'true',
      maxAge: 7 * 24 * 60 * 60 * 1000,
      path: '/api/v1/auth',
    });
  }
}
