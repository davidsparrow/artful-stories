import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';

export default function Home() {
  return (
    <div className="bg-cream-50">
      {/* Hero Section */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="font-serif text-5xl font-bold text-gray-900 sm:text-6xl">
              Captivating personalized placemats
            </h1>
            <p className="mt-6 text-xl text-gray-600 max-w-3xl mx-auto">
              for senior living communities that help residents remember and connect with each other.
            </p>
            <div className="mt-10 flex justify-center gap-4">
              <Link href="/signup">
                <Button size="lg">Get Started</Button>
              </Link>
              <Button variant="outline" size="lg">Learn More</Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="font-serif text-3xl font-bold text-gray-900">
              How It Works
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              Simple, guided process for creating meaningful placemats
            </p>
          </div>
          <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8">
            <Card>
              <CardHeader>
                <CardTitle className="text-center">Choose Template</CardTitle>
                <CardDescription className="text-center">
                  Select from beautiful designs tailored for senior living
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center">
                  <span className="text-gray-500">Template Preview</span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-center">Fill Details</CardTitle>
                <CardDescription className="text-center">
                  Add resident information and upload photos
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center">
                  <span className="text-gray-500">Form Preview</span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-center">Get Proof & Print</CardTitle>
                <CardDescription className="text-center">
                  Review your design and receive high-quality prints
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center">
                  <span className="text-gray-500">Proof Preview</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-blue-50">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="font-serif text-3xl font-bold text-gray-900">
            Ready to create meaningful connections?
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Start designing personalized placemats for your community today.
          </p>
          <div className="mt-8">
            <Link href="/signup">
              <Button size="lg">Start Your First Placemat</Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}