"use client";

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase/client';
import { Button } from '@/components/ui/Button';
import { T } from '@/lib/theme';

interface HeaderProps {
  user?: {
    id: string;
    email?: string;
  } | null;
  profile?: {
    id: string;
    full_name?: string;
    is_platform_admin?: boolean;
  } | null;
}

export function Header({ user, profile }: HeaderProps) {
  const router = useRouter();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push('/');
  };

  return (
    <header style={{
      borderBottom: '1px solid #E8DDD5',
      background: '#fff',
      padding: '16px 0',
    }}>
      <div style={{
        maxWidth: 1200,
        margin: '0 auto',
        padding: '0 24px',
      }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          height: 48,
        }}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <Link
              href="/"
              style={{
                fontFamily: "'Fraunces', serif",
                fontSize: 24,
                fontWeight: 700,
                color: T.brown,
                textDecoration: 'none',
              }}
            >
              StoryMats
            </Link>
          </div>

          <nav style={{
            display: 'none',
            alignItems: 'center',
            gap: 32,
            fontSize: 15,
            fontWeight: 500,
          }}>
            <Link
              href="/products"
              style={{
                color: T.brownM,
                textDecoration: 'none',
                transition: 'color 0.18s',
              }}
              onMouseEnter={(e) => e.currentTarget.style.color = T.orange}
              onMouseLeave={(e) => e.currentTarget.style.color = T.brownM}
            >
              Products
            </Link>
            <Link
              href="/templates"
              style={{
                color: T.brownM,
                textDecoration: 'none',
                transition: 'color 0.18s',
              }}
              onMouseEnter={(e) => e.currentTarget.style.color = T.orange}
              onMouseLeave={(e) => e.currentTarget.style.color = T.brownM}
            >
              Templates
            </Link>
            <Link
              href="/about"
              style={{
                color: T.brownM,
                textDecoration: 'none',
                transition: 'color 0.18s',
              }}
              onMouseEnter={(e) => e.currentTarget.style.color = T.orange}
              onMouseLeave={(e) => e.currentTarget.style.color = T.brownM}
            >
              About
            </Link>
          </nav>

          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            {user ? (
              <>
                <Link href="/dashboard">
                  <Button variant="outline" size="sm">
                    Dashboard
                  </Button>
                </Link>
                {profile?.is_platform_admin && (
                  <Link href="/admin">
                    <Button variant="teal" size="sm">
                      Admin
                    </Button>
                  </Link>
                )}
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={handleLogout}
                >
                  Sign Out
                </Button>
              </>
            ) : (
              <>
                <Link href="/login">
                  <Button variant="outline" size="sm">
                    Sign In
                  </Button>
                </Link>
                <Link href="/signup">
                  <Button size="sm">
                    Get Started
                  </Button>
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}