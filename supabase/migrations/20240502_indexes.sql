-- Add missing indexes for performance
-- Run this after the main schema migration

CREATE INDEX IF NOT EXISTS idx_customers_brand ON customers(brand_id);
CREATE INDEX IF NOT EXISTS idx_customers_org ON customers(organization_id);
CREATE INDEX IF NOT EXISTS idx_customers_profile ON customers(profile_id);

CREATE INDEX IF NOT EXISTS idx_submissions_brand ON submissions(brand_id);
CREATE INDEX IF NOT EXISTS idx_submissions_org ON submissions(organization_id);
CREATE INDEX IF NOT EXISTS idx_submissions_customer ON submissions(customer_id);
CREATE INDEX IF NOT EXISTS idx_submissions_created_by ON submissions(created_by);
CREATE INDEX IF NOT EXISTS idx_submissions_product ON submissions(product_id);
CREATE INDEX IF NOT EXISTS idx_submissions_template ON submissions(template_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);
CREATE INDEX IF NOT EXISTS idx_submissions_current_proof ON submissions(current_proof_id);

CREATE INDEX IF NOT EXISTS idx_submission_field_values_submission ON submission_field_values(submission_id);
CREATE INDEX IF NOT EXISTS idx_submission_field_values_field ON submission_field_values(template_field_id);
CREATE INDEX IF NOT EXISTS idx_submission_field_values_key ON submission_field_values(field_key);

CREATE INDEX IF NOT EXISTS idx_submission_assets_submission ON submission_assets(submission_id);
CREATE INDEX IF NOT EXISTS idx_submission_assets_type ON submission_assets(asset_type);
CREATE INDEX IF NOT EXISTS idx_submission_assets_field ON submission_assets(field_key);

CREATE INDEX IF NOT EXISTS idx_proof_versions_submission ON proof_versions(submission_id);
CREATE INDEX IF NOT EXISTS idx_proof_versions_version ON proof_versions(version_number);
CREATE INDEX IF NOT EXISTS idx_proof_versions_status ON proof_versions(status);

CREATE INDEX IF NOT EXISTS idx_proof_comments_proof ON proof_comments(proof_version_id);
CREATE INDEX IF NOT EXISTS idx_proof_comments_submission ON proof_comments(submission_id);

CREATE INDEX IF NOT EXISTS idx_proof_approvals_proof ON proof_approvals(proof_version_id);
CREATE INDEX IF NOT EXISTS idx_proof_approvals_submission ON proof_approvals(submission_id);
CREATE INDEX IF NOT EXISTS idx_proof_approvals_status ON proof_approvals(approval_status);

CREATE INDEX IF NOT EXISTS idx_review_links_submission ON review_links(submission_id);
CREATE INDEX IF NOT EXISTS idx_review_links_token ON review_links(token);
CREATE INDEX IF NOT EXISTS idx_review_links_expires ON review_links(expires_at);

CREATE INDEX IF NOT EXISTS idx_render_jobs_submission ON render_jobs(submission_id);
CREATE INDEX IF NOT EXISTS idx_render_jobs_proof ON render_jobs(proof_version_id);
CREATE INDEX IF NOT EXISTS idx_render_jobs_order ON render_jobs(order_id);
CREATE INDEX IF NOT EXISTS idx_render_jobs_status ON render_jobs(status);

CREATE INDEX IF NOT EXISTS idx_final_artifacts_submission ON final_artifacts(submission_id);
CREATE INDEX IF NOT EXISTS idx_final_artifacts_order ON final_artifacts(order_id);

CREATE INDEX IF NOT EXISTS idx_orders_brand ON orders(brand_id);
CREATE INDEX IF NOT EXISTS idx_orders_org ON orders(organization_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_by ON orders(created_by);
CREATE INDEX IF NOT EXISTS idx_orders_number ON orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_fulfillment_status ON orders(fulfillment_status);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_submission ON order_items(submission_id);

CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_provider ON payments(provider);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

CREATE INDEX IF NOT EXISTS idx_fulfillment_jobs_order ON fulfillment_jobs(order_id);
CREATE INDEX IF NOT EXISTS idx_fulfillment_jobs_order_item ON fulfillment_jobs(order_item_id);
CREATE INDEX IF NOT EXISTS idx_fulfillment_jobs_provider ON fulfillment_jobs(provider);
CREATE INDEX IF NOT EXISTS idx_fulfillment_jobs_status ON fulfillment_jobs(status);

CREATE INDEX IF NOT EXISTS idx_fulfillment_events_job ON fulfillment_events(fulfillment_job_id);
CREATE INDEX IF NOT EXISTS idx_fulfillment_events_order ON fulfillment_events(order_id);
CREATE INDEX IF NOT EXISTS idx_fulfillment_events_provider ON fulfillment_events(provider);

CREATE INDEX IF NOT EXISTS idx_fulfillment_connections_org ON fulfillment_connections(organization_id);
CREATE INDEX IF NOT EXISTS idx_fulfillment_connections_brand ON fulfillment_connections(brand_id);

CREATE INDEX IF NOT EXISTS idx_template_categories_brand ON template_categories(brand_id);
CREATE INDEX IF NOT EXISTS idx_template_categories_active ON template_categories(is_active);

CREATE INDEX IF NOT EXISTS idx_template_assets_template ON template_assets(template_id);

CREATE INDEX IF NOT EXISTS idx_product_variants_product ON product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_product_variants_active ON product_variants(is_active);

CREATE INDEX IF NOT EXISTS idx_activity_log_org ON activity_log(organization_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_brand ON activity_log(brand_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_profile ON activity_log(profile_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_entity ON activity_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_action ON activity_log(action);

CREATE INDEX IF NOT EXISTS idx_webhook_events_provider ON webhook_events(provider);
CREATE INDEX IF NOT EXISTS idx_webhook_events_processed ON webhook_events(processed);