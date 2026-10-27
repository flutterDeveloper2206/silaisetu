-- CreateEnum
CREATE TYPE "SubscriptionProofStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterEnum
ALTER TYPE "AuditAction" ADD VALUE IF NOT EXISTS 'SUBSCRIPTION_PROOF_SUBMITTED';
ALTER TYPE "AuditAction" ADD VALUE IF NOT EXISTS 'SUBSCRIPTION_PROOF_APPROVED';
ALTER TYPE "AuditAction" ADD VALUE IF NOT EXISTS 'SUBSCRIPTION_PROOF_REJECTED';

-- AlterTable
ALTER TABLE "shops" ADD COLUMN IF NOT EXISTS "subscriptionLifetimeFree" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "shops" ADD COLUMN IF NOT EXISTS "trialEndsAt" TIMESTAMP(3);
ALTER TABLE "shops" ADD COLUMN IF NOT EXISTS "subscriptionExpiresAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE IF NOT EXISTS "subscription_payment_proofs" (
    "id" UUID NOT NULL,
    "shopId" UUID NOT NULL,
    "submittedById" UUID NOT NULL,
    "amountInr" DECIMAL(12,2) NOT NULL,
    "transactionId" TEXT NOT NULL,
    "screenshotUrl" TEXT NOT NULL,
    "note" TEXT,
    "status" "SubscriptionProofStatus" NOT NULL DEFAULT 'PENDING',
    "reviewedById" UUID,
    "reviewedAt" TIMESTAMP(3),
    "reviewNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "subscription_payment_proofs_pkey" PRIMARY KEY ("id")
);

-- Indexes
CREATE INDEX IF NOT EXISTS "shops_subscriptionExpiresAt_idx" ON "shops"("subscriptionExpiresAt");
CREATE INDEX IF NOT EXISTS "subscription_payment_proofs_shopId_status_idx" ON "subscription_payment_proofs"("shopId", "status");
CREATE INDEX IF NOT EXISTS "subscription_payment_proofs_status_createdAt_idx" ON "subscription_payment_proofs"("status", "createdAt");
CREATE INDEX IF NOT EXISTS "subscription_payment_proofs_transactionId_idx" ON "subscription_payment_proofs"("transactionId");

-- FKs
DO $$ BEGIN
  ALTER TABLE "subscription_payment_proofs" ADD CONSTRAINT "subscription_payment_proofs_shopId_fkey"
    FOREIGN KEY ("shopId") REFERENCES "shops"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE "subscription_payment_proofs" ADD CONSTRAINT "subscription_payment_proofs_submittedById_fkey"
    FOREIGN KEY ("submittedById") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE "subscription_payment_proofs" ADD CONSTRAINT "subscription_payment_proofs_reviewedById_fkey"
    FOREIGN KEY ("reviewedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Demo shops: lifetime free so seeded accounts keep working when enforcement is enabled
UPDATE "shops"
SET "subscriptionLifetimeFree" = true
WHERE "slug" IN ('demo-ahmedabad', 'demo-surat', 'admin', 'silaisetu-demo-shop');

-- Existing other shops: 30-day trial from createdAt if not already set
UPDATE "shops"
SET "trialEndsAt" = "createdAt" + INTERVAL '30 days'
WHERE "trialEndsAt" IS NULL
  AND "subscriptionLifetimeFree" = false;
