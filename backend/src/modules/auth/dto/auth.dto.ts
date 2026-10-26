import {
  IsEmail,
  IsEnum,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  MinLength,
  ValidateIf,
} from 'class-validator';
import { LanguageCode, MeasurementUnit, ThemeModePref } from '@prisma/client';

export class RegisterDto {
  @IsString()
  @MinLength(2)
  fullName!: string;

  @ValidateIf((o: RegisterDto) => !o.phone)
  @IsEmail()
  email?: string;

  @ValidateIf((o: RegisterDto) => !o.email)
  @IsString()
  phone?: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsOptional()
  @IsString()
  altPhone?: string;

  @IsOptional()
  @IsEnum(LanguageCode)
  languagePref?: LanguageCode;
}

export class LoginDto {
  /** Email address or mobile number */
  @IsString()
  @MinLength(3)
  identifier!: string;

  @IsString()
  password!: string;
}

/** @deprecated use identifier — kept for web compatibility */
export class LegacyLoginDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsString()
  password!: string;

  @IsOptional()
  @IsString()
  identifier?: string;
}

export class RefreshDto {
  @IsOptional()
  @IsString()
  refreshToken?: string;
}

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  fullName?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  altPhone?: string;

  @IsOptional()
  @IsEnum(LanguageCode)
  languagePref?: LanguageCode;

  @IsOptional()
  @IsEnum(ThemeModePref)
  themePref?: ThemeModePref;

  @IsOptional()
  @IsString()
  avatarUrl?: string;
}

export class ForgotPasswordDto {
  @IsString()
  @MinLength(3)
  identifier!: string;
}

export class ResetPasswordDto {
  @IsString()
  token!: string;

  @IsString()
  @MinLength(8)
  newPassword!: string;
}

export class VerifyOtpDto {
  @IsString()
  @MinLength(3)
  identifier!: string;

  @IsString()
  @MinLength(4)
  code!: string;
}

export class RequestVerifyDto {
  @IsOptional()
  @IsString()
  channel?: 'email' | 'phone';
}

export class ChangePasswordDto {
  @IsString()
  currentPassword!: string;

  @IsString()
  @MinLength(8)
  newPassword!: string;
}

export class ForgotIdentifierDto {
  @IsOptional()
  @IsString()
  recoveryContact?: string;
}

export class OnboardingDraftDto {
  @IsInt()
  @Min(1)
  @Max(5)
  step!: number;

  @IsObject()
  data!: Record<string, unknown>;
}

export class CompleteOnboardingDto {
  @IsString()
  @MinLength(2)
  shopName!: string;

  @IsOptional()
  @IsString()
  ownerDisplayName?: string;

  @IsOptional()
  @IsString()
  shopPhone?: string;

  @IsOptional()
  @IsEmail()
  shopEmail?: string;

  @IsOptional()
  @IsString()
  altPhone?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  logoUrl?: string;

  @IsString()
  addressLine1!: string;

  @IsOptional()
  @IsString()
  addressLine2?: string;

  @IsOptional()
  @IsString()
  area?: string;

  @IsString()
  city!: string;

  @IsString()
  state!: string;

  @IsString()
  pincode!: string;

  @IsOptional()
  @IsString()
  country?: string;

  @IsOptional()
  @IsObject()
  preferences?: Record<string, unknown>;

  @IsOptional()
  @IsEnum(MeasurementUnit)
  measurementUnit?: MeasurementUnit;

  @IsOptional()
  @IsEnum(LanguageCode)
  defaultLanguage?: LanguageCode;

  @IsOptional()
  @IsObject()
  workingHours?: object;

  @IsOptional()
  @IsString()
  receiptHeader?: string;

  @IsOptional()
  @IsString()
  receiptFooter?: string;

  @IsOptional()
  @IsEnum(LanguageCode)
  receiptLanguage?: LanguageCode;

  @IsOptional()
  @IsString()
  receiptContact?: string;

  @IsOptional()
  paymentMethods?: string[];

  @IsOptional()
  @IsString()
  taxId?: string;

  /** Client UUID — prevents duplicate shops on retry */
  @IsUUID()
  idempotencyKey!: string;
}
