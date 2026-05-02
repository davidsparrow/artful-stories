-- Add missing RLS policies and indexes to existing StoryMats schema
-- Run this after the main schema migration to ensure proper security

-- Enable RLS on remaining tables
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_field_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE proof_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE proof_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE proof_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE render_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE final_artifacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE fulfillment_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE fulfillment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE fulfillment_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE template_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE template_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhook_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies for customers
CREATE POLICY "Organization members can view their customers" ON customers
  FOR SELECT USING (is_org_member(organization_id));

CREATE POLICY "Organization members can manage their customers" ON customers
  FOR ALL USING (is_org_member(organization_id) AND has_org_role(organization_id, 'admin'));

CREATE POLICY "Platform admins can manage all customers" ON customers
  FOR ALL USING (is_platform_admin());

-- RLS Policies for submission_field_values
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

-- RLS Policies for submission_assets
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

-- RLS Policies for proof_versions
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

-- RLS Policies for proof_comments
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

-- RLS Policies for proof_approvals
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

-- RLS Policies for review_links
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

-- RLS Policies for render_jobs
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

-- RLS Policies for final_artifacts
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

-- RLS Policies for order_items
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

-- RLS Policies for payments
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

-- RLS Policies for fulfillment_jobs
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

-- RLS Policies for fulfillment_events
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

-- RLS Policies for fulfillment_connections
CREATE POLICY "Organization admins can manage their connections" ON fulfillment_connections
  FOR ALL USING (
    is_org_member(organization_id) AND has_org_role(organization_id, 'admin')
  );

CREATE POLICY "Platform admins can manage all connections" ON fulfillment_connections
  FOR ALL USING (is_platform_admin());

-- RLS Policies for template_categories
CREATE POLICY "Public can view active template categories" ON template_categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Organization admins can manage their categories" ON template_categories
  FOR ALL USING (
    has_org_role((
      SELECT organization_id FROM brands WHERE id = brand_id
    ), 'admin')
  );

-- RLS Policies for template_assets
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

-- RLS Policies for product_variants
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

-- RLS Policies for activity_log
CREATE POLICY "Organization members can view their activity logs" ON activity_log
  FOR SELECT USING (
    organization_id IS NOT NULL AND is_org_member(organization_id) OR
    brand_id IS NOT NULL AND is_org_member((
      SELECT organization_id FROM brands WHERE id = brand_id
    )) OR
    profile_id = auth.uid() OR
    is_platform_admin()
  );

-- RLS Policies for webhook_events
CREATE POLICY "Platform admins can access webhook events" ON webhook_events
  FOR ALL USING (is_platform_admin());