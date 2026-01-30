import Head from 'next/head'
import Link from 'next/link'

export default function Home() {
  return (
    <div className="min-h-screen bg-gray-100">
      <Head>
        <title>SentinelAI X - Autonomous Cyber Defense Platform</title>
        <meta name="description" content="Advanced AI-powered cybersecurity platform" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">SentinelAI X</h1>
            </div>
            <div className="flex items-center space-x-4">
              <Link href="/login" prefetch={false} className="text-gray-600 hover:text-gray-900">
                Login
              </Link>
              <Link href="/docs" className="text-gray-600 hover:text-gray-900">
                Documentation
              </Link>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Autonomous Cyber Defense and Simulated Counter-Offensive Learning System
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Advanced AI-powered cybersecurity platform designed to autonomously detect, analyze, and neutralize cyber threats
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-xl font-semibold mb-3">Threat Detection</h3>
            <p className="text-gray-600">
              Real-time detection of malware, trojans, ransomware, phishing, and zero-day exploits using advanced ML models
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-xl font-semibold mb-3">Document Learning</h3>
            <p className="text-gray-600">
              Automatically extract and learn from cybersecurity documents, research papers, and threat reports using NLP
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-xl font-semibold mb-3">Simulation Engine</h3>
            <p className="text-gray-600">
              Simulate cyber-offensive strategies in sandboxed environments to strengthen defensive capabilities
            </p>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-8">
          <h3 className="text-2xl font-semibold mb-4">Key Features</h3>
          <ul className="list-disc list-inside space-y-2 text-gray-600">
            <li>Autonomous AI-driven cyber defense system</li>
            <li>Real-time threat detection and analysis</li>
            <li>Document-based learning from cybersecurity research</li>
            <li>Sandboxed simulation of attack scenarios</li>
            <li>Automated defense response and mitigation</li>
            <li>Continuous learning and adaptation</li>
            <li>Comprehensive threat intelligence dashboard</li>
          </ul>
        </div>

        <div className="mt-12 text-center">
          <Link
            href="/dashboard"
            className="inline-block bg-blue-600 text-white px-8 py-3 rounded-lg text-lg font-semibold hover:bg-blue-700"
          >
            Get Started
          </Link>
        </div>
      </main>

      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
          <p className="text-center text-gray-600">
            © 2024 SentinelAI X. All rights reserved. Ethical cybersecurity platform for defense purposes only.
          </p>
        </div>
      </footer>
    </div>
  )
}
