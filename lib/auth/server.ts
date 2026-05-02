import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';

export async function getCurrentUser() {
  const supabase = await createClient();
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    return null;
  }

  return user;
}

export async function getCurrentProfile() {
  const supabase = await createClient();
  const user = await getCurrentUser();

  if (!user) return null;

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (error) return null;

  return profile;
}

export async function getCurrentOrganization() {
  const profile = await getCurrentProfile();
  if (!profile?.default_organization_id) return null;

  const supabase = await createClient();
  const { data: organization, error } = await supabase
    .from('organizations')
    .select('*')
    .eq('id', profile.default_organization_id)
    .single();

  if (error) return null;

  return organization;
}

export async function getUserOrganizations() {
  const profile = await getCurrentProfile();
  if (!profile) return [];

  const supabase = await createClient();
  const { data: memberships, error } = await supabase
    .from('organization_memberships')
    .select(`
      role,
      organizations (
        id,
        name,
        slug,
        organization_type
      )
    `)
    .eq('profile_id', profile.id);

  if (error) return [];

  return memberships.map(m => ({
    ...m.organizations,
    role: m.role,
  }));
}

export async function requireUser() {
  const user = await getCurrentUser();
  if (!user) {
    redirect('/login');
  }
  return user;
}

export async function requirePlatformAdmin() {
  const profile = await getCurrentProfile();
  if (!profile?.is_platform_admin) {
    redirect('/dashboard');
  }
  return profile;
}