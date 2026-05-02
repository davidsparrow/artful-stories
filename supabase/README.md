# StoryMats Supabase Schema

This document describes the database schema for the StoryMats platform.

## Overview

StoryMats is a multi-tenant platform for creating personalized guided custom products. The schema supports:

- Multiple organizations and brands
- Guided template-driven product customization
- Proof approval workflows
- Order management and fulfillment
- Extensible for future SaaS sellers

## Core Architecture

### Multi-Tenant Design

- **Organizations**: Top-level entities (companies, facilities, families)
- **Brands**: Public-facing storefronts under organizations
- **Users**: Platform users with role-based access

### Product System

- **Products**: Sellable items (placemats, posters, etc.)
- **Templates**: Locked design templates with defined fields
- **Submissions**: Customer customization attempts

### Workflow

1. Customer selects product and template
2. Fills guided form with text/images
3. System generates proof for review
4. Customer approves or requests changes
5. Payment and final render
6. Fulfillment via Printful or other providers

## Key Tables

### Core Entities
- `profiles` - User profiles (extends Supabase auth)
- `organizations` - Companies/facilities/families
- `organization_memberships` - User roles in organizations
- `brands` - Public storefronts

### Products & Templates
- `products` - Sellable product types
- `product_variants` - Specific purchasable variants
- `template_categories` - Template organization
- `templates` - Design templates
- `template_fields` - Form fields for templates
- `template_assets` - Template media assets

### Submissions & Proofing
- `customers` - Customer identities
- `submissions` - Customization submissions
- `submission_field_values` - Field responses
- `submission_assets` - Uploaded images/assets
- `proof_versions` - Generated proof images
- `proof_comments` - Review comments
- `proof_approvals` - Approval records
- `review_links` - Secure sharing links

### Orders & Fulfillment
- `orders` - Customer orders
- `order_items` - Line items
- `payments` - Payment records
- `render_jobs` - Background rendering tasks
- `final_artifacts` - Print-ready files
- `fulfillment_jobs` - Print provider orders
- `fulfillment_events` - Status webhooks

### System
- `activity_log` - Audit trail
- `webhook_events` - External webhook storage

## Enums

All status and type fields use Postgres enums for data integrity.

## Row Level Security (RLS)

Comprehensive RLS policies ensure:
- Users can access their own data
- Organization members can access org data based on roles
- Public read access for active products/templates
- Platform admins have full access

## Storage Buckets

- `template-assets` - Template backgrounds, samples, overlays
- `submission-uploads` - Customer uploads and derivatives
- `proof-renders` - Proof images for review
- `final-artifacts` - Production-ready print files
- `brand-assets` - Logos and marketing materials

## Migration

Run the schema migration:
```sql
-- Execute supabase/migrations/20240502_initial_schema.sql
```

## Seed Data

The migration includes initial seed data for:
- StoryMats organization and brand
- Resident Bio Placemat product
- Classic Resident Story template with 10 fields + 24 item fields

## Future Extensions

The schema is designed to support:
- Multiple fulfillment providers
- SaaS seller onboarding
- Template marketplaces
- Advanced image processing
- Facility bulk ordering
- International shipping/taxes