-- SilaiSetu Row-Level Security (tenant isolation defense-in-depth)
-- Apply AFTER Prisma migrations as a privileged role (table owner).
-- Runtime app connections should use silaisetu_app (non-owner) so RLS is enforced.
--
-- Backend authorization remains mandatory; RLS is a second layer.
-- Tenant context: SET LOCAL app.current_shop_id = '<uuid>';

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers FORCE ROW LEVEL SECURITY;
ALTER TABLE garment_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE garment_templates FORCE ROW LEVEL SECURITY;
ALTER TABLE measurement_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE measurement_records FORCE ROW LEVEL SECURITY;
ALTER TABLE stitching_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE stitching_orders FORCE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items FORCE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments FORCE ROW LEVEL SECURITY;
ALTER TABLE shop_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_memberships FORCE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications FORCE ROW LEVEL SECURITY;

-- Drop if re-running
DO $$ BEGIN
  -- customers
  DROP POLICY IF EXISTS tenant_isolation_customers ON customers;
  CREATE POLICY tenant_isolation_customers ON customers
    USING (shop_id::text = current_setting('app.current_shop_id', true));

  DROP POLICY IF EXISTS tenant_isolation_garment_templates ON garment_templates;
  CREATE POLICY tenant_isolation_garment_templates ON garment_templates
    USING (shop_id::text = current_setting('app.current_shop_id', true));

  DROP POLICY IF EXISTS tenant_isolation_measurements ON measurement_records;
  CREATE POLICY tenant_isolation_measurements ON measurement_records
    USING (shop_id::text = current_setting('app.current_shop_id', true));

  DROP POLICY IF EXISTS tenant_isolation_orders ON stitching_orders;
  CREATE POLICY tenant_isolation_orders ON stitching_orders
    USING (shop_id::text = current_setting('app.current_shop_id', true));

  DROP POLICY IF EXISTS tenant_isolation_payments ON payments;
  CREATE POLICY tenant_isolation_payments ON payments
    USING (shop_id::text = current_setting('app.current_shop_id', true));

  DROP POLICY IF EXISTS tenant_isolation_memberships ON shop_memberships;
  CREATE POLICY tenant_isolation_memberships ON shop_memberships
    USING (shop_id::text = current_setting('app.current_shop_id', true));

  DROP POLICY IF EXISTS tenant_isolation_notifications ON notifications;
  CREATE POLICY tenant_isolation_notifications ON notifications
    USING (
      shop_id IS NULL
      OR shop_id::text = current_setting('app.current_shop_id', true)
    );
END $$;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO silaisetu_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO silaisetu_app;

-- NOTE: Prisma migrations typically run as table owner (bypasses RLS).
-- Wire SET LOCAL app.current_shop_id in a Prisma middleware / interactive
-- transaction before enabling DATABASE_URL_APP in production-like envs.
-- Current local default uses owner role + NestJS tenant filters.
