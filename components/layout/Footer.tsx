import Link from 'next/link';

export function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-white">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h3 className="font-serif text-lg font-semibold text-gray-900">StoryMats</h3>
            <p className="mt-4 text-sm text-gray-600">
              Captivating personalized placemats for senior living communities that help residents remember and connect with each other.
            </p>
          </div>
          <div>
            <h4 className="font-medium text-gray-900">Products</h4>
            <ul className="mt-4 space-y-2 text-sm text-gray-600">
              <li><Link href="/products">Placemats</Link></li>
              <li><Link href="/templates">Templates</Link></li>
              <li><Link href="/pricing">Pricing</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="font-medium text-gray-900">Company</h4>
            <ul className="mt-4 space-y-2 text-sm text-gray-600">
              <li><Link href="/about">About</Link></li>
              <li><Link href="/contact">Contact</Link></li>
              <li><Link href="/faq">FAQ</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="font-medium text-gray-900">Support</h4>
            <ul className="mt-4 space-y-2 text-sm text-gray-600">
              <li><Link href="/help">Help Center</Link></li>
              <li><Link href="/privacy">Privacy Policy</Link></li>
              <li><Link href="/terms">Terms of Service</Link></li>
            </ul>
          </div>
        </div>
        <div className="mt-8 border-t border-gray-200 pt-8 text-center text-sm text-gray-600">
          <p>&copy; 2026 StoryMats. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}