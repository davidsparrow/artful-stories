-- StoryMats Supabase Schema Migration
-- Version: 0.1
-- Date: 2026-05-02
-- Description: Initial schema for guided custom product platform

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enums (using IF NOT EXISTS to make migration idempotent)
DO $$ BEGIN
    CREATE TYPE organization_type AS ENUM (
      'platform_owner',
      'seller',
      'care_facility',
      'family',
      'print_partner'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE membership_role AS ENUM (
      'owner',
      'admin',
      'manager',
      'designer',
      'customer_support',
      'facility_admin',
      'facility_staff',
      'viewer'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE brand_type AS ENUM (
      'internal',
      'seller',
      'facility',
      'white_label'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE product_type AS ENUM (
      'placemat',
      'poster',
      'card',
      'digital_download',
      'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE template_status AS ENUM (
      'draft',
      'active',
      'inactive',
      'archived'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE field_type AS ENUM (
      'text',
      'textarea',
      'image',
      'date',
      'year',
      'location',
      'select',
      'multi_select',
      'boolean',
      'quote',
      'map_point',
      'number',
      'email',
      'phone',
      'url'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE submission_status AS ENUM (
      'draft',
      'submitted',
      'proof_generating',
      'proof_ready',
      'revision_requested',
      'approved',
      'locked',
      'archived',
      'canceled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE proof_status AS ENUM (
      'pending',
      'generated',
      'approved',
      'revision_requested',
      'superseded',
      'failed'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE approval_status AS ENUM (
      'pending',
      'approved',
      'rejected',
      'revoked'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM (
      'unpaid',
      'checkout_started',
      'paid',
      'payment_failed',
      'refunded',
      'partially_refunded',
      'canceled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE fulfillment_status AS ENUM (
      'not_ready',
      'ready_to_submit',
      'submitted_to_printful',
      'in_production',
      'shipped',
      'delivered',
      'failed',
      'canceled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE asset_type AS ENUM (
      'original_upload',
      'cropped_image',
      'proof_image',
      'final_print_image',
      'sample_image',
      'template_background',
      'template_overlay',
      'font_file_reference',
      'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE reviewer_permission AS ENUM (
      'view_only',
      'comment',
      'approve'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Helper functions for RLS
CREATE OR REPLACE FUNCTION is_platform_admin(user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = user_id AND is_platform_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_org_member(org_id UUID, user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM organization_memberships
    WHERE organization_id = org_id AND profile_id = user_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION has_org_role(org_id UUID, required_role membership_role, user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM organization_memberships
    WHERE organization_id = org_id
      AND profile_id = user_id
      AND role IN (
        CASE
          WHEN required_role = 'owner' THEN ARRAY['owner'::membership_role]
          WHEN required_role = 'admin' THEN ARRAY['owner'::membership_role, 'admin'::membership_role]
          WHEN required_role = 'manager' THEN ARRAY['owner'::membership_role, 'admin'::membership_role, 'manager'::membership_role]
          ELSE ARRAY['owner'::membership_role, 'admin'::membership_role, 'manager'::membership_role, 'designer'::membership_role, 'customer_support'::membership_role, 'facility_admin'::membership_role, 'facility_staff'::membership_role, 'viewer'::membership_role]
        END
      )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Core tables

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  default_organization_id UUID,
  is_platform_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  organization_type organization_type NOT NULL DEFAULT 'family',
  billing_email TEXT,
  website_url TEXT,
  logo_url TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_organizations_updated_at ON organizations;
CREATE TRIGGER update_organizations_updated_at
  BEFORE UPDATE ON organizations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS organization_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role membership_role NOT NULL DEFAULT 'viewer',
  invited_email TEXT,
  invited_by UUID REFERENCES profiles(id),
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (organization_id, profile_id)
);

DROP TRIGGER IF EXISTS update_organization_memberships_updated_at ON organization_memberships;
CREATE TRIGGER update_organization_memberships_updated_at
  BEFORE UPDATE ON organization_memberships
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  brand_type brand_type NOT NULL DEFAULT 'internal',
  logo_url TEXT,
  primary_color TEXT,
  secondary_color TEXT,
  accent_color TEXT,
  domain TEXT,
  support_email TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
DROP TRIGGER IF EXISTS update_brands_updated_at ON brands;
CREATE TRIGGER update_brands_updated_at
  BEFORE UPDATE ON brands
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Products and templates

CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  product_type product_type NOT NULL DEFAULT 'placemat',
  base_price_cents INTEGER NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'usd',
  is_active BOOLEAN DEFAULT true,
  requires_customization BOOLEAN DEFAULT true,
  requires_proof_approval BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (brand_id, slug)
);
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS product_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sku TEXT,
  price_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  quantity_included INTEGER DEFAULT 1,
  is_digital BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  print_width_inches NUMERIC(8,2),
  print_height_inches NUMERIC(8,2),
  target_dpi INTEGER DEFAULT 300,
  final_width_px INTEGER,
  final_height_px INTEGER,
  safe_zone_json JSONB DEFAULT '{}',
  bleed_json JSONB DEFAULT '{}',
  fulfillment_provider TEXT DEFAULT 'printful',
  fulfillment_product_id TEXT,
  fulfillment_variant_id TEXT,
  fulfillment_config JSONB DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_product_variants_updated_at ON product_variants;
CREATE TRIGGER update_product_variants_updated_at
  BEFORE UPDATE ON product_variants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_template_categories_updated_at ON template_categories;
CREATE TRIGGER update_template_categories_updated_at
  BEFORE UPDATE ON template_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  category_id UUID REFERENCES template_categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  status template_status NOT NULL DEFAULT 'draft',
  item_count INTEGER,
  renderer_key TEXT NOT NULL,
  sample_image_url TEXT,
  thumbnail_url TEXT,
  canvas_width_px INTEGER NOT NULL,
  canvas_height_px INTEGER NOT NULL,
  preview_width_px INTEGER DEFAULT 1400,
  preview_height_px INTEGER DEFAULT 1000,
  target_dpi INTEGER DEFAULT 300,
  requires_background_removed_images BOOLEAN DEFAULT false,
  supports_proof_render BOOLEAN DEFAULT true,
  supports_final_render BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (brand_id, slug)
);

CREATE TABLE IF NOT EXISTS template_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
  field_key TEXT NOT NULL,
  label TEXT NOT NULL,
  help_text TEXT,
  placeholder TEXT,
  field_type field_type NOT NULL,
  is_required BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  max_chars INTEGER,
  min_chars INTEGER,
  max_lines INTEGER,
  validation_regex TEXT,
  image_aspect_ratio TEXT,
  image_min_width_px INTEGER,
  image_min_height_px INTEGER,
  image_requires_transparency BOOLEAN DEFAULT false,
  image_slot_width_px INTEGER,
  image_slot_height_px INTEGER,
  select_options JSONB DEFAULT '[]',
  default_value JSONB,
  conditional_logic JSONB DEFAULT '{}',
  render_config JSONB DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (template_id, field_key)
);

CREATE TABLE IF NOT EXISTS template_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
  asset_type asset_type NOT NULL,
  label TEXT,
  storage_path TEXT,
  public_url TEXT,
  mime_type TEXT,
  width_px INTEGER,
  height_px INTEGER,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customers and submissions

CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id),
  profile_id UUID REFERENCES profiles(id),
  email TEXT,
  full_name TEXT,
  phone TEXT,
  shipping_name TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id),
  customer_id UUID REFERENCES customers(id),
  created_by UUID REFERENCES profiles(id),
  product_id UUID NOT NULL REFERENCES products(id),
  product_variant_id UUID REFERENCES product_variants(id),
  template_id UUID NOT NULL REFERENCES templates(id),
  title TEXT,
  status submission_status NOT NULL DEFAULT 'draft',
  submitted_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  locked_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ,
  current_proof_id UUID,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS submission_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  uploaded_by UUID REFERENCES profiles(id),
  asset_type asset_type NOT NULL DEFAULT 'original_upload',
  field_key TEXT,
  original_filename TEXT,
  storage_path TEXT NOT NULL,
  public_url TEXT,
  mime_type TEXT,
  file_size_bytes BIGINT,
  width_px INTEGER,
  height_px INTEGER,
  crop_json JSONB DEFAULT '{}',
  quality_warnings JSONB DEFAULT '[]',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS submission_field_values (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  template_field_id UUID NOT NULL REFERENCES template_fields(id) ON DELETE CASCADE,
  field_key TEXT NOT NULL,
  field_type field_type NOT NULL,
  value_text TEXT,
  value_json JSONB,
  asset_id UUID REFERENCES submission_assets(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (submission_id, field_key)
);

-- Proofing

CREATE TABLE IF NOT EXISTS proof_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  status proof_status NOT NULL DEFAULT 'pending',
  proof_image_asset_id UUID REFERENCES submission_assets(id),
  proof_image_url TEXT,
  watermarked BOOLEAN DEFAULT true,
  render_job_id UUID,
  renderer_key TEXT,
  render_inputs_snapshot JSONB DEFAULT '{}',
  render_error TEXT,
  generated_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  superseded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (submission_id, version_number)
);

CREATE TABLE IF NOT EXISTS proof_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proof_version_id UUID NOT NULL REFERENCES proof_versions(id) ON DELETE CASCADE,
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  commented_by_profile_id UUID REFERENCES profiles(id),
  commented_by_name TEXT,
  commented_by_email TEXT,
  is_admin_comment BOOLEAN DEFAULT false,
  is_customer_visible BOOLEAN DEFAULT true,
  comment_text TEXT NOT NULL,
  annotation_json JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS proof_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proof_version_id UUID NOT NULL REFERENCES proof_versions(id) ON DELETE CASCADE,
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  approved_by_profile_id UUID REFERENCES profiles(id),
  approved_by_name TEXT,
  approved_by_email TEXT,
  approval_status approval_status NOT NULL DEFAULT 'pending',
  approval_ip INET,
  approval_user_agent TEXT,
  approval_statement TEXT,
  approved_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS review_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  proof_version_id UUID REFERENCES proof_versions(id) ON DELETE CASCADE,
  token TEXT UNIQUE NOT NULL,
  created_by UUID REFERENCES profiles(id),
  reviewer_name TEXT,
  reviewer_email TEXT,
  permission reviewer_permission NOT NULL DEFAULT 'view_only',
  expires_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  last_accessed_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rendering

CREATE TABLE IF NOT EXISTS render_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  proof_version_id UUID REFERENCES proof_versions(id) ON DELETE SET NULL,
  order_id UUID,
  job_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'queued',
  renderer_key TEXT NOT NULL,
  requested_by UUID REFERENCES profiles(id),
  input_snapshot JSONB DEFAULT '{}',
  output_asset_id UUID REFERENCES submission_assets(id),
  output_url TEXT,
  error_message TEXT,
  attempt_count INTEGER DEFAULT 0,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  failed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS final_artifacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  order_id UUID,
  asset_id UUID NOT NULL REFERENCES submission_assets(id),
  file_url TEXT NOT NULL,
  width_px INTEGER,
  height_px INTEGER,
  dpi INTEGER,
  format TEXT DEFAULT 'png',
  checksum TEXT,
  created_from_proof_version_id UUID REFERENCES proof_versions(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders and payments

CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id),
  customer_id UUID REFERENCES customers(id),
  created_by UUID REFERENCES profiles(id),
  order_number TEXT UNIQUE NOT NULL,
  payment_status payment_status NOT NULL DEFAULT 'unpaid',
  fulfillment_status fulfillment_status NOT NULL DEFAULT 'not_ready',
  subtotal_cents INTEGER NOT NULL DEFAULT 0,
  discount_cents INTEGER NOT NULL DEFAULT 0,
  tax_cents INTEGER NOT NULL DEFAULT 0,
  shipping_cents INTEGER NOT NULL DEFAULT 0,
  total_cents INTEGER NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'usd',
  shipping_name TEXT,
  shipping_line1 TEXT,
  shipping_line2 TEXT,
  shipping_city TEXT,
  shipping_state TEXT,
  shipping_postal_code TEXT,
  shipping_country TEXT,
  shipping_phone TEXT,
  stripe_checkout_session_id TEXT,
  stripe_payment_intent_id TEXT,
  paid_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  submission_id UUID REFERENCES submissions(id),
  product_id UUID NOT NULL REFERENCES products(id),
  product_variant_id UUID REFERENCES product_variants(id),
  template_id UUID REFERENCES templates(id),
  name TEXT NOT NULL,
  sku TEXT,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price_cents INTEGER NOT NULL,
  total_price_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  final_artifact_id UUID REFERENCES final_artifacts(id),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  provider TEXT NOT NULL DEFAULT 'stripe',
  provider_payment_id TEXT,
  provider_checkout_session_id TEXT,
  status payment_status NOT NULL,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  raw_event JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Fulfillment

CREATE TABLE IF NOT EXISTS fulfillment_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  order_item_id UUID REFERENCES order_items(id),
  provider TEXT NOT NULL DEFAULT 'printful',
  status fulfillment_status NOT NULL DEFAULT 'not_ready',
  provider_order_id TEXT,
  provider_order_item_id TEXT,
  provider_status TEXT,
  request_payload JSONB DEFAULT '{}',
  response_payload JSONB DEFAULT '{}',
  error_message TEXT,
  submitted_at TIMESTAMPTZ,
  shipped_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  tracking_number TEXT,
  tracking_url TEXT,
  carrier TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fulfillment_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fulfillment_job_id UUID REFERENCES fulfillment_jobs(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  event_type TEXT,
  provider_event_id TEXT,
  payload JSONB DEFAULT '{}',
  received_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fulfillment_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  brand_id UUID REFERENCES brands(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  display_name TEXT,
  access_token_encrypted TEXT,
  refresh_token_encrypted TEXT,
  external_store_id TEXT,
  is_active BOOLEAN DEFAULT true,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (organization_id, brand_id, provider)
);

-- Logging

CREATE TABLE IF NOT EXISTS activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  brand_id UUID REFERENCES brands(id),
  profile_id UUID REFERENCES profiles(id),
  entity_type TEXT NOT NULL,
  entity_id UUID,
  action TEXT NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider TEXT NOT NULL,
  event_id TEXT,
  event_type TEXT,
  payload JSONB NOT NULL,
  processed BOOLEAN DEFAULT false,
  processed_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (provider, event_id)
);

-- Indexes for performance

-- Profiles
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_default_org ON profiles(default_organization_id);

-- Organizations
CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_type ON organizations(organization_type);

-- Organization memberships
CREATE INDEX idx_org_memberships_org_profile ON organization_memberships(organization_id, profile_id);
CREATE INDEX idx_org_memberships_profile ON organization_memberships(profile_id);

-- Brands
CREATE INDEX idx_brands_org ON brands(organization_id);
CREATE INDEX idx_brands_slug ON brands(slug);

-- Products
CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_products_brand_slug ON products(brand_id, slug);
CREATE INDEX idx_products_active ON products(is_active);

-- Product variants
CREATE INDEX idx_product_variants_product ON product_variants(product_id);
CREATE INDEX idx_product_variants_active ON product_variants(is_active);

-- Template categories
CREATE INDEX idx_template_categories_brand ON template_categories(brand_id);
CREATE INDEX idx_template_categories_active ON template_categories(is_active);

-- Templates
CREATE INDEX idx_templates_brand ON templates(brand_id);
CREATE INDEX idx_templates_brand_slug ON templates(brand_id, slug);
CREATE INDEX idx_templates_product ON templates(product_id);
CREATE INDEX idx_templates_category ON templates(category_id);
CREATE INDEX idx_templates_status ON templates(status);
CREATE INDEX idx_templates_active ON templates(status) WHERE status = 'active';

-- Template fields
CREATE INDEX idx_template_fields_template ON template_fields(template_id);
CREATE INDEX idx_template_fields_key ON template_fields(field_key);

-- Customers
CREATE INDEX idx_customers_brand ON customers(brand_id);
CREATE INDEX idx_customers_org ON customers(organization_id);
CREATE INDEX idx_customers_profile ON customers(profile_id);

-- Submissions
CREATE INDEX idx_submissions_brand ON submissions(brand_id);
CREATE INDEX idx_submissions_org ON submissions(organization_id);
CREATE INDEX idx_submissions_customer ON submissions(customer_id);
CREATE INDEX idx_submissions_created_by ON submissions(created_by);
CREATE INDEX idx_submissions_product ON submissions(product_id);
CREATE INDEX idx_submissions_template ON submissions(template_id);
CREATE INDEX idx_submissions_status ON submissions(status);
CREATE INDEX idx_submissions_current_proof ON submissions(current_proof_id);

-- Submission field values
CREATE INDEX idx_submission_field_values_submission ON submission_field_values(submission_id);
CREATE INDEX idx_submission_field_values_field ON submission_field_values(template_field_id);
CREATE INDEX idx_submission_field_values_key ON submission_field_values(field_key);

-- Submission assets
CREATE INDEX idx_submission_assets_submission ON submission_assets(submission_id);
CREATE INDEX idx_submission_assets_type ON submission_assets(asset_type);
CREATE INDEX idx_submission_assets_field ON submission_assets(field_key);

-- Proof versions
CREATE INDEX idx_proof_versions_submission ON proof_versions(submission_id);
CREATE INDEX idx_proof_versions_version ON proof_versions(version_number);
CREATE INDEX idx_proof_versions_status ON proof_versions(status);

-- Proof comments
CREATE INDEX idx_proof_comments_proof ON proof_comments(proof_version_id);
CREATE INDEX idx_proof_comments_submission ON proof_comments(submission_id);

-- Proof approvals
CREATE INDEX idx_proof_approvals_proof ON proof_approvals(proof_version_id);
CREATE INDEX idx_proof_approvals_submission ON proof_approvals(submission_id);
CREATE INDEX idx_proof_approvals_status ON proof_approvals(approval_status);

-- Review links
CREATE INDEX idx_review_links_submission ON review_links(submission_id);
CREATE INDEX idx_review_links_token ON review_links(token);
CREATE INDEX idx_review_links_expires ON review_links(expires_at);

-- Render jobs
CREATE INDEX idx_render_jobs_submission ON render_jobs(submission_id);
CREATE INDEX idx_render_jobs_proof ON render_jobs(proof_version_id);
CREATE INDEX idx_render_jobs_order ON render_jobs(order_id);
CREATE INDEX idx_render_jobs_status ON render_jobs(status);

-- Final artifacts
CREATE INDEX idx_final_artifacts_submission ON final_artifacts(submission_id);
CREATE INDEX idx_final_artifacts_order ON final_artifacts(order_id);

-- Orders
CREATE INDEX idx_orders_brand ON orders(brand_id);
CREATE INDEX idx_orders_org ON orders(organization_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_created_by ON orders(created_by);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_fulfillment_status ON orders(fulfillment_status);

-- Order items
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_submission ON order_items(submission_id);

-- Payments
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_provider ON payments(provider);
CREATE INDEX idx_payments_status ON payments(status);

-- Fulfillment jobs
CREATE INDEX idx_fulfillment_jobs_order ON fulfillment_jobs(order_id);
CREATE INDEX idx_fulfillment_jobs_order_item ON fulfillment_jobs(order_item_id);
CREATE INDEX idx_fulfillment_jobs_provider ON fulfillment_jobs(provider);
CREATE INDEX idx_fulfillment_jobs_status ON fulfillment_jobs(status);

-- Fulfillment events
CREATE INDEX idx_fulfillment_events_job ON fulfillment_events(fulfillment_job_id);
CREATE INDEX idx_fulfillment_events_order ON fulfillment_events(order_id);
CREATE INDEX idx_fulfillment_events_provider ON fulfillment_events(provider);

-- Fulfillment connections
CREATE INDEX idx_fulfillment_connections_org ON fulfillment_connections(organization_id);
CREATE INDEX idx_fulfillment_connections_brand ON fulfillment_connections(brand_id);

-- Activity log
CREATE INDEX idx_activity_log_org ON activity_log(organization_id);
CREATE INDEX idx_activity_log_brand ON activity_log(brand_id);
CREATE INDEX idx_activity_log_profile ON activity_log(profile_id);
CREATE INDEX idx_activity_log_entity ON activity_log(entity_type, entity_id);
CREATE INDEX idx_activity_log_action ON activity_log(action);

-- Webhook events
CREATE INDEX idx_webhook_events_provider ON webhook_events(provider);
CREATE INDEX idx_webhook_events_processed ON webhook_events(processed);

-- RLS Policies

-- Profiles: Users can read/update their own profile, admins can read all
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Platform admins can view all profiles" ON profiles
  FOR SELECT USING (is_platform_admin());

-- Organizations: Members can read their orgs, admins can manage
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Organization members can view their organizations" ON organizations
  FOR SELECT USING (is_org_member(id));

CREATE POLICY "Platform admins can view all organizations" ON organizations
  FOR SELECT USING (is_platform_admin());

CREATE POLICY "Platform admins can manage all organizations" ON organizations
  FOR ALL USING (is_platform_admin());

-- Organization memberships: Members can read memberships in their orgs
ALTER TABLE organization_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view memberships in their organizations" ON organization_memberships
  FOR SELECT USING (is_org_member(organization_id));

CREATE POLICY "Organization admins can manage memberships" ON organization_memberships
  FOR ALL USING (has_org_role(organization_id, 'admin'));

CREATE POLICY "Platform admins can view all memberships" ON organization_memberships
  FOR SELECT USING (is_platform_admin());

-- Brands: Public can read active brands, org members can manage their brands
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active brands" ON brands
  FOR SELECT USING (true); -- Allow public read for now, filter active in app

CREATE POLICY "Organization members can manage their brands" ON brands
  FOR ALL USING (is_org_member(organization_id) AND has_org_role(organization_id, 'admin'));

CREATE POLICY "Platform admins can manage all brands" ON brands
  FOR ALL USING (is_platform_admin());

-- Products: Public can read active products, org admins can manage
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active products" ON products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Organization admins can manage their products" ON products
  FOR ALL USING (has_org_role((SELECT organization_id FROM brands WHERE id = brand_id), 'admin'));

CREATE POLICY "Platform admins can manage all products" ON products
  FOR ALL USING (is_platform_admin());

-- Templates: Public can read active templates, org admins can manage
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active templates" ON templates
  FOR SELECT USING (status = 'active');

CREATE POLICY "Organization admins can manage their templates" ON templates
  FOR ALL USING (has_org_role((SELECT organization_id FROM brands WHERE id = brand_id), 'admin'));

CREATE POLICY "Platform admins can manage all templates" ON templates
  FOR ALL USING (is_platform_admin());

-- Template fields: Follow template permissions
ALTER TABLE template_fields ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view fields for active templates" ON template_fields
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM templates
      WHERE id = template_id AND status = 'active'
    )
  );

CREATE POLICY "Organization admins can manage template fields" ON template_fields
  FOR ALL USING (
    has_org_role((
      SELECT b.organization_id FROM templates t
      JOIN brands b ON t.brand_id = b.id
      WHERE t.id = template_id
    ), 'admin')
  );

-- Submissions: Owners can manage their drafts, org admins can manage org submissions
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own draft submissions" ON submissions
  FOR ALL USING (
    created_by = auth.uid() AND status = 'draft'
  );

CREATE POLICY "Organization admins can manage org submissions" ON submissions
  FOR ALL USING (
    organization_id IS NOT NULL AND has_org_role(organization_id, 'admin')
  );

CREATE POLICY "Platform admins can manage all submissions" ON submissions
  FOR ALL USING (is_platform_admin());

-- Orders: Customers can read their orders, org admins can manage org orders
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view their orders" ON orders
  FOR SELECT USING (
    customer_id IN (
      SELECT id FROM customers WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "Organization admins can manage org orders" ON orders
  FOR ALL USING (
    organization_id IS NOT NULL AND has_org_role(organization_id, 'admin')
  );

CREATE POLICY "Platform admins can manage all orders" ON orders
  FOR ALL USING (is_platform_admin());

-- Comprehensive RLS policies for all tables in the StoryMats platform

-- Customers: Organization members can access their org customers
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Organization members can view their customers" ON customers
  FOR SELECT USING (is_org_member(organization_id));

CREATE POLICY "Organization members can manage their customers" ON customers
  FOR ALL USING (is_org_member(organization_id) AND has_org_role(organization_id, 'admin'));

CREATE POLICY "Platform admins can manage all customers" ON customers
  FOR ALL USING (is_platform_admin());

-- Submission field values: Follow submission permissions
ALTER TABLE submission_field_values ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their submission field values" ON submission_field_values
  FOR ALL USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Submission assets: Follow submission permissions
ALTER TABLE submission_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their submission assets" ON submission_assets
  FOR ALL USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Proof versions: Follow submission permissions
ALTER TABLE proof_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their proof versions" ON proof_versions
  FOR SELECT USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Proof comments: Follow submission permissions
ALTER TABLE proof_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their proof comments" ON proof_comments
  FOR SELECT USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

CREATE POLICY "Users can manage their proof comments" ON proof_comments
  FOR ALL USING (
    commented_by_profile_id = auth.uid() OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Proof approvals: Follow submission permissions
ALTER TABLE proof_approvals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their proof approvals" ON proof_approvals
  FOR SELECT USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

CREATE POLICY "Users can manage their proof approvals" ON proof_approvals
  FOR ALL USING (
    approved_by_profile_id = auth.uid() OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Review links: Secure access via tokens (handled by application logic)
ALTER TABLE review_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their review links" ON review_links
  FOR SELECT USING (
    created_by = auth.uid() OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

CREATE POLICY "Users can manage their review links" ON review_links
  FOR ALL USING (
    created_by = auth.uid() OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Render jobs: Follow submission permissions
ALTER TABLE render_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their render jobs" ON render_jobs
  FOR SELECT USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Final artifacts: Follow submission permissions
ALTER TABLE final_artifacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their final artifacts" ON final_artifacts
  FOR SELECT USING (
    submission_id IN (
      SELECT id FROM submissions WHERE created_by = auth.uid()
    ) OR
    submission_id IN (
      SELECT s.id FROM submissions s
      WHERE s.organization_id IS NOT NULL AND has_org_role(s.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Order items: Follow order permissions
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view their order items" ON order_items
  FOR SELECT USING (
    order_id IN (
      SELECT o.id FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE c.profile_id = auth.uid()
    ) OR
    order_id IN (
      SELECT o.id FROM orders o
      WHERE o.organization_id IS NOT NULL AND has_org_role(o.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Payments: Follow order permissions
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view their payments" ON payments
  FOR SELECT USING (
    order_id IN (
      SELECT o.id FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE c.profile_id = auth.uid()
    ) OR
    order_id IN (
      SELECT o.id FROM orders o
      WHERE o.organization_id IS NOT NULL AND has_org_role(o.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Fulfillment jobs: Follow order permissions
ALTER TABLE fulfillment_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view their fulfillment jobs" ON fulfillment_jobs
  FOR SELECT USING (
    order_id IN (
      SELECT o.id FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE c.profile_id = auth.uid()
    ) OR
    order_id IN (
      SELECT o.id FROM orders o
      WHERE o.organization_id IS NOT NULL AND has_org_role(o.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Fulfillment events: Follow order permissions
ALTER TABLE fulfillment_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view their fulfillment events" ON fulfillment_events
  FOR SELECT USING (
    order_id IN (
      SELECT o.id FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE c.profile_id = auth.uid()
    ) OR
    order_id IN (
      SELECT o.id FROM orders o
      WHERE o.organization_id IS NOT NULL AND has_org_role(o.organization_id, 'admin')
    ) OR
    fulfillment_job_id IN (
      SELECT fj.id FROM fulfillment_jobs fj
      JOIN orders o ON fj.order_id = o.id
      WHERE o.organization_id IS NOT NULL AND has_org_role(o.organization_id, 'admin')
    ) OR
    is_platform_admin()
  );

-- Fulfillment connections: Organization admins can manage their connections
ALTER TABLE fulfillment_connections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Organization admins can manage their connections" ON fulfillment_connections
  FOR ALL USING (
    is_org_member(organization_id) AND has_org_role(organization_id, 'admin')
  );

CREATE POLICY "Platform admins can manage all connections" ON fulfillment_connections
  FOR ALL USING (is_platform_admin());

-- Template categories: Public read, org admins manage
ALTER TABLE template_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active template categories" ON template_categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Organization admins can manage their categories" ON template_categories
  FOR ALL USING (
    has_org_role((
      SELECT organization_id FROM brands WHERE id = brand_id
    ), 'admin')
  );

CREATE POLICY "Platform admins can manage all categories" ON template_categories
  FOR ALL USING (is_platform_admin());

-- Template assets: Follow template permissions
ALTER TABLE template_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view assets for active templates" ON template_assets
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM templates
      WHERE id = template_id AND status = 'active'
    )
  );

CREATE POLICY "Organization admins can manage template assets" ON template_assets
  FOR ALL USING (
    has_org_role((
      SELECT b.organization_id FROM templates t
      JOIN brands b ON t.brand_id = b.id
      WHERE t.id = template_id
    ), 'admin')
  );

-- Product variants: Follow product permissions
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active product variants" ON product_variants
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM products
      WHERE id = product_id AND is_active = true
    )
  );

CREATE POLICY "Organization admins can manage their variants" ON product_variants
  FOR ALL USING (
    has_org_role((
      SELECT b.organization_id FROM products p
      JOIN brands b ON p.brand_id = b.id
      WHERE p.id = product_id
    ), 'admin')
  );

CREATE POLICY "Platform admins can manage all variants" ON product_variants
  FOR ALL USING (is_platform_admin());

-- Activity log: Organization members can view their org logs
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Organization members can view their activity logs" ON activity_log
  FOR SELECT USING (
    organization_id IS NOT NULL AND is_org_member(organization_id) OR
    brand_id IS NOT NULL AND is_org_member((
      SELECT organization_id FROM brands WHERE id = brand_id
    )) OR
    profile_id = auth.uid() OR
    is_platform_admin()
  );

-- Webhook events: Platform admins only (sensitive data)
ALTER TABLE webhook_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Platform admins can access webhook events" ON webhook_events
  FOR ALL USING (is_platform_admin());

-- Seed data

-- Organization
INSERT INTO organizations (id, name, slug, organization_type) VALUES
  ('550e8400-e29b-41d4-a716-446655440000', 'StoryMats', 'storymats', 'platform_owner');

-- Brand
INSERT INTO brands (id, organization_id, name, slug, brand_type) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'StoryMats', 'storymats', 'internal');

-- Product
INSERT INTO products (id, brand_id, name, slug, product_type, base_price_cents, requires_customization, requires_proof_approval) VALUES
  ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Resident Bio Placemat', 'resident-bio-placemat', 'placemat', 7900, true, true);

-- Product variant
INSERT INTO product_variants (id, product_id, name, price_cents, print_width_inches, print_height_inches, target_dpi, final_width_px, final_height_px) VALUES
  ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '14x10 Premium Placemat', 7900, 14.0, 10.0, 300, 4200, 3000);

-- Template category
INSERT INTO template_categories (id, brand_id, name, slug, is_active) VALUES
  ('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'Resident Stories', 'resident-stories', true);

-- Template
INSERT INTO templates (id, brand_id, product_id, category_id, name, slug, status, item_count, renderer_key, canvas_width_px, canvas_height_px, preview_width_px, preview_height_px) VALUES
  ('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 'Classic Resident Story — 8 Item', 'classic-resident-story-8', 'active', 8, 'classic_resident_story_8', 4200, 3000, 1400, 1000);

-- Template fields
INSERT INTO template_fields (id, template_id, field_key, label, field_type, is_required, sort_order, max_chars, image_aspect_ratio) VALUES
  ('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440005', 'resident_name', 'Resident Name', 'text', true, 1, 40, NULL),
  ('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440005', 'preferred_name', 'Preferred Name', 'text', false, 2, 30, NULL),
  ('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440005', 'portrait_photo', 'Portrait Photo', 'image', true, 3, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440005', 'hometown', 'Hometown', 'text', false, 4, 60, NULL),
  ('550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440005', 'favorite_song', 'Favorite Song', 'text', false, 5, 60, NULL),
  ('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440005', 'favorite_food', 'Favorite Food', 'text', false, 6, 60, NULL),
  ('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440005', 'career_or_calling', 'Career or Calling', 'text', false, 7, 80, NULL),
  ('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440005', 'family_names', 'Family Names', 'textarea', false, 8, 160, NULL),
  ('550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440005', 'quote', 'Quote', 'quote', false, 9, 120, NULL),
  ('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440005', 'ask_me_about', 'Ask Me About', 'textarea', false, 10, 160, NULL);

-- Item fields 1-8
INSERT INTO template_fields (id, template_id, field_key, label, field_type, is_required, sort_order, max_chars, max_lines, image_aspect_ratio) VALUES
  ('550e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440005', 'item_1_photo', 'Item 1 Photo', 'image', false, 11, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440005', 'item_1_title', 'Item 1 Title', 'text', false, 12, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440005', 'item_1_description', 'Item 1 Description', 'textarea', false, 13, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440019', '550e8400-e29b-41d4-a716-446655440005', 'item_2_photo', 'Item 2 Photo', 'image', false, 14, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440005', 'item_2_title', 'Item 2 Title', 'text', false, 15, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440005', 'item_2_description', 'Item 2 Description', 'textarea', false, 16, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440005', 'item_3_photo', 'Item 3 Photo', 'image', false, 17, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440005', 'item_3_title', 'Item 3 Title', 'text', false, 18, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440005', 'item_3_description', 'Item 3 Description', 'textarea', false, 19, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440005', 'item_4_photo', 'Item 4 Photo', 'image', false, 20, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440005', 'item_4_title', 'Item 4 Title', 'text', false, 21, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440005', 'item_4_description', 'Item 4 Description', 'textarea', false, 22, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440005', 'item_5_photo', 'Item 5 Photo', 'image', false, 23, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440005', 'item_5_title', 'Item 5 Title', 'text', false, 24, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440005', 'item_5_description', 'Item 5 Description', 'textarea', false, 25, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440005', 'item_6_photo', 'Item 6 Photo', 'image', false, 26, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440005', 'item_6_title', 'Item 6 Title', 'text', false, 27, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440005', 'item_6_description', 'Item 6 Description', 'textarea', false, 28, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440005', 'item_7_photo', 'Item 7 Photo', 'image', false, 29, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440035', '550e8400-e29b-41d4-a716-446655440005', 'item_7_title', 'Item 7 Title', 'text', false, 30, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440036', '550e8400-e29b-41d4-a716-446655440005', 'item_7_description', 'Item 7 Description', 'textarea', false, 31, 120, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440037', '550e8400-e29b-41d4-a716-446655440005', 'item_8_photo', 'Item 8 Photo', 'image', false, 32, NULL, NULL, '1:1'),
  ('550e8400-e29b-41d4-a716-446655440038', '550e8400-e29b-41d4-a716-446655440005', 'item_8_title', 'Item 8 Title', 'text', false, 33, 36, NULL, NULL),
  ('550e8400-e29b-41d4-a716-446655440039', '550e8400-e29b-41d4-a716-446655440005', 'item_8_description', 'Item 8 Description', 'textarea', false, 34, 120, NULL, NULL);

-- Storage buckets (these would be created via Supabase dashboard or CLI)
-- template-assets: For template sample images, backgrounds, overlays, thumbnails
-- submission-uploads: For customer original uploads and cropped derivatives
-- proof-renders: For proof PNGs
-- final-artifacts: For final print-ready PNG files
-- brand-assets: For logos and public marketing images