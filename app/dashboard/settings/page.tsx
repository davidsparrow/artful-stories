import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { getCurrentProfile, getUserOrganizations } from '@/lib/auth/server';
import { T } from '@/lib/theme';

export default async function SettingsPage() {
  const profile = await getCurrentProfile();
  const organizations = await getUserOrganizations();

  // Filter out any null organizations
  const validOrganizations = organizations.filter((org) =>
    org && typeof org === 'object' && 'id' in org
  );

  return (
    <div style={{
      minHeight: '100vh',
      background: T.cream,
      padding: '48px 24px',
    }}>
      <div style={{
        maxWidth: 800,
        margin: '0 auto',
      }}>
        <div style={{ marginBottom: 48 }}>
          <h1 style={{
            fontFamily: "'Fraunces', serif",
            fontSize: 48,
            fontWeight: 700,
            color: T.brown,
            marginBottom: 8,
          }}>
            Account Settings
          </h1>
          <p style={{
            fontSize: 18,
            color: T.brownM,
          }}>
            Manage your account preferences and organization settings.
          </p>
        </div>

        <div style={{ display: 'grid', gap: 24 }}>
          <Card>
            <CardHeader>
              <CardTitle>Profile Information</CardTitle>
              <CardDescription>Update your personal details</CardDescription>
            </CardHeader>
            <CardContent style={{ display: 'grid', gap: 16 }}>
              <div>
                <label style={{
                  display: 'block',
                  fontSize: 14,
                  fontWeight: 600,
                  color: T.brown,
                  marginBottom: 4,
                }}>
                  Full Name
                </label>
                <Input
                  defaultValue={profile?.full_name || ''}
                  placeholder="Enter your full name"
                />
              </div>

              <div>
                <label style={{
                  display: 'block',
                  fontSize: 14,
                  fontWeight: 600,
                  color: T.brown,
                  marginBottom: 4,
                }}>
                  Email
                </label>
                <Input
                  type="email"
                  defaultValue={profile?.email || ''}
                  disabled
                  style={{ opacity: 0.6 }}
                />
                <p style={{
                  fontSize: 12,
                  color: T.brownM,
                  marginTop: 4,
                }}>
                  Email cannot be changed. Contact support if needed.
                </p>
              </div>

              <div>
                <label style={{
                  display: 'block',
                  fontSize: 14,
                  fontWeight: 600,
                  color: T.brown,
                  marginBottom: 4,
                }}>
                  Phone (optional)
                </label>
                <Input
                  type="tel"
                  defaultValue={profile?.phone || ''}
                  placeholder="Enter your phone number"
                />
              </div>

              <Button style={{ alignSelf: 'flex-start' }}>
                Save Changes
              </Button>
            </CardContent>
          </Card>

          {organizations.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Your Organizations</CardTitle>
                <CardDescription>Organizations you belong to</CardDescription>
              </CardHeader>
              <CardContent style={{ display: 'grid', gap: 16 }}>
                {validOrganizations.map((org: any) => (
                  <div key={org.id} style={{
                    padding: 16,
                    background: '#F7F2ED',
                    borderRadius: 12,
                    border: '1px solid #E8DDD5',
                  }}>
                    <div style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}>
                      <div>
                        <h3 style={{
                          fontSize: 18,
                          fontWeight: 600,
                          color: T.brown,
                          marginBottom: 4,
                        }}>
                          {org.name}
                        </h3>
                        <p style={{
                          fontSize: 14,
                          color: T.brownM,
                        }}>
                          Role: {org.role} • Type: {org.organization_type?.replace('_', ' ')}
                        </p>
                      </div>
                      <Button variant="outline" size="sm">
                        Manage
                      </Button>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader>
              <CardTitle>Account Actions</CardTitle>
              <CardDescription>Danger zone - irreversible actions</CardDescription>
            </CardHeader>
            <CardContent>
              <Button variant="red" size="sm">
                Delete Account
              </Button>
              <p style={{
                fontSize: 12,
                color: T.brownM,
                marginTop: 8,
              }}>
                This action cannot be undone. All your data will be permanently deleted.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}