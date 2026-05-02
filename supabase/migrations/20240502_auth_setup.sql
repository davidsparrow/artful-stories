-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  default_org_id UUID;
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name');

  -- Create default organization for new users
  INSERT INTO public.organizations (name, slug, organization_type)
  VALUES (
    COALESCE(new.raw_user_meta_data->>'full_name', 'Personal') || '''s Organization',
    'user-' || new.id,
    'family'
  )
  RETURNING id INTO default_org_id;

  -- Create organization membership
  INSERT INTO public.organization_memberships (organization_id, profile_id, role)
  VALUES (default_org_id, new.id, 'owner');

  -- Update profile with default organization
  UPDATE public.profiles
  SET default_organization_id = default_org_id
  WHERE id = new.id;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function on new user
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();