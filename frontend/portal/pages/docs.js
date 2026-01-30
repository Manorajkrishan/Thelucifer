import Head from 'next/head'
import Link from 'next/link'

export default function Docs() {
  return (
    <div className="min-h-screen bg-gray-100">
      <Head>
        <title>Documentation - SentinelAI X</title>
        <meta name="description" content="SentinelAI X Documentation" />
      </Head>

      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Link href="/" className="text-2xl font-bold text-gray-900">
                SentinelAI X
              </Link>
            </div>
            <div className="flex items-center space-x-4">
              <Link href="/" className="text-gray-600 hover:text-gray-900">
                Home
              </Link>
              <Link href="/docs" className="text-blue-600 font-semibold">
                Docs
              </Link>
              <Link href="/login" prefetch={false} className="text-gray-600 hover:text-gray-900">
                Login
              </Link>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="bg-white rounded-lg shadow p-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-6">Documentation</h1>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">Getting Started</h2>
            <p className="text-gray-600 mb-4">
              SentinelAI X is an advanced AI-powered cybersecurity platform designed to autonomously detect, analyze, and neutralize cyber threats.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">API Documentation</h2>
            <div className="space-y-4">
              <div className="border-l-4 border-blue-500 pl-4">
                <h3 className="font-semibold text-gray-900 mb-2">Authentication</h3>
                <code className="block bg-gray-100 p-2 rounded text-sm">POST /api/login</code>
                <code className="block bg-gray-100 p-2 rounded text-sm mt-2">POST /api/register</code>
              </div>

              <div className="border-l-4 border-green-500 pl-4">
                <h3 className="font-semibold text-gray-900 mb-2">Threats</h3>
                <code className="block bg-gray-100 p-2 rounded text-sm">GET /api/threats</code>
                <code className="block bg-gray-100 p-2 rounded text-sm mt-2">POST /api/threats</code>
                <code className="block bg-gray-100 p-2 rounded text-sm mt-2">GET /api/threats/statistics</code>
              </div>

              <div className="border-l-4 border-purple-500 pl-4">
                <h3 className="font-semibold text-gray-900 mb-2">Documents</h3>
                <code className="block bg-gray-100 p-2 rounded text-sm">GET /api/documents</code>
                <code className="block bg-gray-100 p-2 rounded text-sm mt-2">POST /api/documents</code>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">Features</h2>
            <ul className="list-disc list-inside space-y-2 text-gray-600">
              <li>Real-time threat detection</li>
              <li>Document-based learning</li>
              <li>Cyber-offensive simulation</li>
              <li>Automated defense responses</li>
              <li>Knowledge graph management</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4">Support</h2>
            <p className="text-gray-600">
              For more information, please refer to the README.md file in the project repository.
            </p>
          </section>
        </div>
      </main>
    </div>
  )
}
