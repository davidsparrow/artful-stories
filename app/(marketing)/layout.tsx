import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { getCurrentUser, getCurrentProfile } from '@/lib/auth/server';

export default async function MarketingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const user = await getCurrentUser();
  const profile = user ? await getCurrentProfile() : null;

  return (
    <>
      <Header user={user} profile={profile} />
      <main style={{ flex: 1 }}>{children}</main>
      <Footer />
    </>
  );
}