-- Application role that cannot bypass RLS (not table owner).
-- Migrations run as POSTGRES_USER (owner). Runtime should use silaisetu_app.
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'silaisetu_app') THEN
    CREATE ROLE silaisetu_app LOGIN PASSWORD 'silaisetu_app_dev_only';
  END IF;
END
$$;

GRANT CONNECT ON DATABASE silaisetu TO silaisetu_app;
GRANT USAGE ON SCHEMA public TO silaisetu_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO silaisetu_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO silaisetu_app;
