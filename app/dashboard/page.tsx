import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { getCurrentProfile, getCurrentOrganization } from '@/lib/auth/server';
import Link from 'next/link';
import { T } from '@/lib/theme';

export default async function Dashboard() {
  const profile = await getCurrentProfile();
  const organization = await getCurrentOrganization();

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
            Welcome back{profile?.full_name ? `, ${profile.full_name}` : ''}!
          </h1>
          <p style={{
            fontSize: 18,
            color: T.brownM,
            marginBottom: 16,
          }}>
            {organization ? `Managing ${organization.name}` : 'Manage your placemat submissions and orders.'}
          </p>
          <Link href="/dashboard/settings">
            <Button variant="outline" size="sm">
              Account Settings
            </Button>
          </Link>
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
          gap: 24,
          marginBottom: 48,
        }}>
          <Card>
            <CardHeader>
              <CardTitle>Draft Submissions</CardTitle>
              <CardDescription>Submissions you&apos;re currently working on</CardDescription>
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
              <CardTitle>Pending Approval</CardTitle>
              <CardDescription>Submissions awaiting proof approval</CardDescription>
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
              <CardTitle>Completed Orders</CardTitle>
              <CardDescription>Successfully fulfilled orders</CardDescription>
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
        </div>

        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: 24,
        }}>
          <h2 style={{
            fontFamily: "'Fraunces', serif",
            fontSize: 32,
            fontWeight: 700,
            color: T.brown,
          }}>
            Recent Submissions
          </h2>
          <Link href="/dashboard/new">
            <Button size="lg">
              Start a new StoryMat
            </Button>
          </Link>
        </div>

        <Card>
          <CardContent style={{ padding: 48, textAlign: 'center' }}>
            <div style={{
              fontSize: 18,
              color: T.brownM,
              marginBottom: 24,
            }}>
              <p>No submissions yet. Create your first personalized placemat to get started!</p>
            </div>
            <Link href="/dashboard/new">
              <Button size="lg">
                Create Your First Placemat
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}