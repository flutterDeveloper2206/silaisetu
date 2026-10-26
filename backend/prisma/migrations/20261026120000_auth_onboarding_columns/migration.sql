-- CreateEnum
CREATE TYPE "AuthTokenPurpose" AS ENUM ('PASSWORD_RESET', 'EMAIL_VERIFY', 'PHONE_VERIFY', 'RECOVERY_HINT');

-- DropIndex
DROP INDEX "users_phone_idx";

-- AlterTable
ALTER TABLE "shop_settings" ADD COLUMN     "paymentMethods" JSONB,
ADD COLUMN     "receiptContact" TEXT,
ADD COLUMN     "receiptHeader" TEXT,
ADD COLUMN     "receiptLanguage" "LanguageCode" NOT NULL DEFAULT 'gu',
ADD COLUMN     "taxId" TEXT;

-- AlterTable
ALTER TABLE "shops" ADD COLUMN     "addressLine1" TEXT,
ADD COLUMN     "addressLine2" TEXT,
ADD COLUMN     "altPhone" TEXT,
ADD COLUMN     "area" TEXT,
ADD COLUMN     "country" TEXT NOT NULL DEFAULT 'IN',
ADD COLUMN     "createIdempotencyKey" TEXT,
ADD COLUMN     "description" TEXT,
ADD COLUMN     "logoUrl" TEXT,
ADD COLUMN     "onboardingCompletedAt" TIMESTAMP(3),
ADD COLUMN     "ownerDisplayName" TEXT;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "altPhone" TEXT,
ADD COLUMN     "avatarUrl" TEXT,
ADD COLUMN     "onboardingCompletedAt" TIMESTAMP(3),
ADD COLUMN     "onboardingDraft" JSONB,
ADD COLUMN     "onboardingStep" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "phoneVerifiedAt" TIMESTAMP(3),
ALTER COLUMN "email" DROP NOT NULL,
ALTER COLUMN "languagePref" SET DEFAULT 'gu';

-- CreateTable
CREATE TABLE "auth_tokens" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "purpose" "AuthTokenPurpose" NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "meta" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "auth_tokens_userId_purpose_idx" ON "auth_tokens"("userId", "purpose");

-- CreateIndex
CREATE INDEX "auth_tokens_tokenHash_idx" ON "auth_tokens"("tokenHash");

-- CreateIndex
CREATE UNIQUE INDEX "shops_createIdempotencyKey_key" ON "shops"("createIdempotencyKey");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- AddForeignKey
ALTER TABLE "auth_tokens" ADD CONSTRAINT "auth_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
