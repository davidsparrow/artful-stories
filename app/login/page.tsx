"use client";

import { useState } from 'react';
import { supabase } from '@/lib/supabase/client';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');
    setLoading(true);



    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        setError(error.message);
      } else {
        router.push('/dashboard');
      }
    } catch {
      setError('An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: '#FFF8F0',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 24,
    }}>
      <Card style={{ maxWidth: 400, width: '100%' }}>
        <CardHeader>
          <CardTitle>Welcome Back</CardTitle>
          <CardDescription>
            Sign in to your StoryMats account
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <div>
              <label style={{
                display: 'block',
                fontSize: 14,
                fontWeight: 600,
                color: '#3D2B1F',
                marginBottom: 4,
              }}>
                Email
              </label>
              <Input
                type="email"
                value={email}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
                required
                placeholder="your@email.com"
              />
            </div>

            <div>
              <label style={{
                display: 'block',
                fontSize: 14,
                fontWeight: 600,
                color: '#3D2B1F',
                marginBottom: 4,
              }}>
                Password
              </label>
              <Input
                type="password"
                value={password}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)}
                required
                placeholder="••••••••"
              />
            </div>

            {error && (
              <div style={{
                padding: 12,
                background: '#E53E3E22',
                border: '1px solid #E53E3E',
                borderRadius: 8,
                color: '#E53E3E',
                fontSize: 14,
              }}>
                {error}
              </div>
            )}

            <Button
              type="submit"
              disabled={loading}
              style={{ width: '100%' }}
            >
              {loading ? 'Signing In...' : 'Sign In'}
            </Button>
          </form>

          <div style={{ textAlign: 'center', marginTop: 24 }}>
            <span style={{ color: '#6B4226', fontSize: 14 }}>
              Don&apos;t have an account?{' '}
              <Link
                href="/signup"
                style={{
                  color: '#FF6B35',
                  textDecoration: 'underline',
                  fontWeight: 600,
                }}
              >
                Sign up
              </Link>
            </span>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}