// Basic type definitions
// These will be expanded as we implement features

export interface User {
  id: string;
  email: string;
  full_name?: string;
}

export interface Submission {
  id: string;
  title?: string;
  status: 'draft' | 'submitted' | 'proof_ready' | 'approved' | 'completed';
  created_at: string;
  updated_at: string;
}

export interface Template {
  id: string;
  name: string;
  description?: string;
  sample_image_url?: string;
  status: 'active' | 'inactive';
}

export interface Product {
  id: string;
  name: string;
  description?: string;
  base_price_cents: number;
}