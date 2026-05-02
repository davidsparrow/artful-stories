import { Header } from '@/components/layout/Header';
import { requireUser } from '@/lib/auth/server';

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const user = await requireUser();
  const { getCurrentProfile } = await import('@/lib/auth/server');
  const profile = await getCurrentProfile();

  return (
    <>
      <Header user={user} profile={profile} />
      {children}
    </>
  );
}