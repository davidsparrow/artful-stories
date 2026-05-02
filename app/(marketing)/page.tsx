import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';
import { T } from '@/lib/theme';

export default function Home() {
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
        {/* Hero Section */}
        <section style={{ marginBottom: 48 }}>
          <div style={{ textAlign: 'center' }}>
            <h1 style={{
              fontFamily: "'Fraunces', serif",
              fontSize: 48,
              fontWeight: 700,
              color: T.brown,
              marginBottom: 24,
            }}>
              Captivating personalized placemats
            </h1>
            <p style={{
              fontFamily: "'Fraunces', serif",
              fontSize: 20,
              color: T.brown,
              maxWidth: 768,
              margin: '0 auto 32px',
            }}>
              for senior living communities that help residents remember and connect with each other.
            </p>
            <div style={{
              display: 'flex',
              justifyContent: 'center',
              gap: 16,
            }}>
              <Link href="/signup">
                <Button size="lg">Get Started</Button>
              </Link>
              <Button variant="outline" size="lg">Learn More</Button>
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section style={{ marginBottom: 48 }}>
          <div style={{ textAlign: 'center', marginBottom: 64 }}>
            <h2 style={{
              fontFamily: "'Fraunces', serif",
              fontSize: 32,
              fontWeight: 700,
              color: T.brown,
              marginBottom: 16,
            }}>
              How It Works
            </h2>
            <p style={{
              fontFamily: "'Fraunces', serif",
              fontSize: 18,
              color: T.brownM,
            }}>
              Simple, guided process for creating meaningful placemats
            </p>
          </div>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
            gap: 24,
          }}>
            <Card>
              <CardHeader>
                <CardTitle style={{ textAlign: 'center' }}>Choose Template</CardTitle>
                <CardDescription style={{ textAlign: 'center' }}>
                  Select from beautiful designs tailored for senior living
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div style={{
                  aspectRatio: '1',
                  background: '#f3f4f6',
                  borderRadius: 8,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <span style={{ color: '#6b7280' }}>Template Preview</span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle style={{ textAlign: 'center' }}>Fill Details</CardTitle>
                <CardDescription style={{ textAlign: 'center' }}>
                  Add resident information and upload photos
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div style={{
                  aspectRatio: '1',
                  background: '#f3f4f6',
                  borderRadius: 8,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <span style={{ color: '#6b7280' }}>Form Preview</span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle style={{ textAlign: 'center' }}>Get Proof & Print</CardTitle>
                <CardDescription style={{ textAlign: 'center' }}>
                  Review your design and receive high-quality prints
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div style={{
                  aspectRatio: '1',
                  background: '#f3f4f6',
                  borderRadius: 8,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <span style={{ color: '#6b7280' }}>Proof Preview</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </section>

        {/* CTA Section */}
        <section style={{ textAlign: 'center' }}>
          <h2 style={{
            fontFamily: "'Fraunces', serif",
            fontSize: 32,
            fontWeight: 700,
            color: T.brown,
            marginBottom: 16,
          }}>
            Ready to create meaningful connections?
          </h2>
          <p style={{
            fontFamily: "'Fraunces', serif",
            fontSize: 18,
            color: T.brownM,
            marginBottom: 32,
          }}>
            Start designing personalized placemats for your community today.
          </p>
          <div>
            <Link href="/signup">
              <Button size="lg">Start Your First Placemat</Button>
            </Link>
          </div>
        </section>
      </div>
    </div>
  );
}