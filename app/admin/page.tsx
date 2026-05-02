import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';
import { requirePlatformAdmin } from '@/lib/auth/server';
import { T } from '@/lib/theme';

export default async function AdminDashboard() {
  await requirePlatformAdmin();

  return (
    <div style={{
      minHeight: '100vh',
      background: T.cream,
      padding: '48px 24px',
    }}>
      <div style={{
        maxWidth: 1200,
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
            Admin Dashboard
          </h1>
          <p style={{
            fontSize: 18,
            color: T.brownM,
          }}>
            Manage templates, submissions, and orders across the platform.
          </p>
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
          gap: 24,
          marginBottom: 48,
        }}>
          <Card>
            <CardHeader>
              <CardTitle>Total Submissions</CardTitle>
              <CardDescription>All submissions across the platform</CardDescription>
            </CardHeader>
            <CardContent>
              <div style={{
                fontSize: 48,
                fontWeight: 700,
                color: T.brown,
              }}>
                0
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Pending Proofs</CardTitle>
              <CardDescription>Submissions needing proof generation</CardDescription>
            </CardHeader>
            <CardContent>
              <div style={{
                fontSize: 48,
                fontWeight: 700,
                color: T.brown,
              }}>
                0
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Active Templates</CardTitle>
              <CardDescription>Published templates available to users</CardDescription>
            </CardHeader>
            <CardContent>
              <div style={{
                fontSize: 48,
                fontWeight: 700,
                color: T.brown,
              }}>
                1
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Revenue</CardTitle>
              <CardDescription>Total platform revenue</CardDescription>
            </CardHeader>
            <CardContent>
              <div style={{
                fontSize: 48,
                fontWeight: 700,
                color: T.orange,
              }}>
                $0
              </div>
            </CardContent>
          </Card>
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: 24,
        }}>
          <Card>
            <CardHeader>
              <CardTitle>Recent Submissions</CardTitle>
              <CardDescription>Latest customer submissions</CardDescription>
            </CardHeader>
            <CardContent style={{ padding: 48, textAlign: 'center' }}>
              <div style={{
                fontSize: 18,
                color: T.brownM,
              }}>
                <p>No submissions yet.</p>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>System Status</CardTitle>
              <CardDescription>Platform health and integrations</CardDescription>
            </CardHeader>
            <CardContent style={{ display: 'grid', gap: 12 }}>
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '12px 16px',
                background: '#F7F2ED',
                borderRadius: 8,
              }}>
                <span style={{ fontWeight: 500, color: T.brown }}>Supabase</span>
                <span style={{
                  fontSize: 12,
                  fontWeight: 600,
                  color: T.green,
                  background: T.greenP,
                  padding: '4px 8px',
                  borderRadius: 12,
                }}>
                  Connected
                </span>
              </div>

              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '12px 16px',
                background: '#F7F2ED',
                borderRadius: 8,
              }}>
                <span style={{ fontWeight: 500, color: T.brown }}>Printful</span>
                <span style={{
                  fontSize: 12,
                  fontWeight: 600,
                  color: T.brownM,
                  background: '#E8DDD5',
                  padding: '4px 8px',
                  borderRadius: 12,
                }}>
                  Not configured
                </span>
              </div>

              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '12px 16px',
                background: '#F7F2ED',
                borderRadius: 8,
              }}>
                <span style={{ fontWeight: 500, color: T.brown }}>Stripe</span>
                <span style={{
                  fontSize: 12,
                  fontWeight: 600,
                  color: T.brownM,
                  background: '#E8DDD5',
                  padding: '4px 8px',
                  borderRadius: 12,
                }}>
                  Not configured
                </span>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}