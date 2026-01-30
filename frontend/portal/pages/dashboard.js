import { useState, useEffect } from 'react'
import Head from 'next/head'
import Link from 'next/link'
import { useRouter } from 'next/router'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default function Dashboard() {
  const router = useRouter()
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState(null)
  const [recentThreats, setRecentThreats] = useState([])
  const [documentsCount, setDocumentsCount] = useState(0)

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (storedToken) {
      fetchDashboardData(storedToken)
      // Refresh every 30 seconds
      const interval = setInterval(() => {
        fetchDashboardData(storedToken)
      }, 30000)
      return () => clearInterval(interval)
    } else {
      setLoading(false)
    }
  }, [])

  const fetchDashboardData = async (authToken) => {
    try {
      // Fetch statistics
      const statsResponse = await fetch(`${API_URL}/api/threats/statistics`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (statsResponse.ok) {
        const statsData = await statsResponse.json()
        setStats(statsData.data || statsData)
      }

      // Fetch recent threats
      const threatsResponse = await fetch(`${API_URL}/api/threats?per_page=5`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (threatsResponse.ok) {
        const threatsData = await threatsResponse.json()
        let threatsArray = []
        if (threatsData.success && threatsData.data?.data) {
          threatsArray = threatsData.data.data
        } else if (Array.isArray(threatsData.data)) {
          threatsArray = threatsData.data
        }
        setRecentThreats(Array.isArray(threatsArray) ? threatsArray : [])
      }

      // Fetch documents count
      const docsResponse = await fetch(`${API_URL}/api/documents?per_page=1`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (docsResponse.ok) {
        const docsData = await docsResponse.json()
        if (docsData.success && docsData.data) {
          const total = docsData.data.total || docsData.data.data?.length || 0
          setDocumentsCount(total)
        }
      }

    } catch (err) {
      console.error('Failed to fetch dashboard data:', err)
    } finally {
      setLoading(false)
    }
  }

  const activeThreats = stats ? (stats.by_status?.detected || 0) + (stats.by_status?.analyzing || 0) : 0
  const resolvedThreats = stats?.by_status?.resolved || 0
  const totalThreats = stats?.total || 0

  return (
    <>
      <Head>
        <title>Dashboard - SentinelAI X</title>
        <meta name="description" content="SentinelAI X Dashboard" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="min-h-screen bg-gray-100">
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
                <Link href="/dashboard" className="text-blue-600 font-semibold">
                  Dashboard
                </Link>
                <Link href="/threats" className="text-gray-600 hover:text-gray-900">
                  Threats
                </Link>
                <Link href="/documents" className="text-gray-600 hover:text-gray-900">
                  Documents
                </Link>
                <Link href="/simulations" className="text-gray-600 hover:text-gray-900">
                  Simulations
                </Link>
                <Link href="/analytics" className="text-gray-600 hover:text-gray-900">
                  Analytics
                </Link>
                <Link href="/learning" className="text-gray-600 hover:text-gray-900">
                  Learning
                </Link>
              </div>
            </div>
          </div>
        </nav>

        <main className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-gray-900 mb-2">Dashboard</h1>
            <p className="text-xl text-gray-600">Monitor and manage your cybersecurity operations</p>
          </div>

          {!token ? (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
              <p className="text-yellow-800 mb-4">Please login to view dashboard</p>
              <Link href="/login" prefetch={false} className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Go to Login
              </Link>
            </div>
          ) : loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Loading dashboard...</p>
            </div>
          ) : (
            <>
              {/* Stats Cards */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">Active Threats</h3>
                  <p className="text-3xl font-bold text-red-600">{activeThreats}</p>
                  <p className="text-sm text-gray-500 mt-2">
                    {stats?.by_status?.detected || 0} detected, {stats?.by_status?.analyzing || 0} analyzing
                  </p>
                </div>

                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">Documents Processed</h3>
                  <p className="text-3xl font-bold text-blue-600">{documentsCount}</p>
                  <p className="text-sm text-gray-500 mt-2">Total documents in system</p>
                </div>

                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">System Status</h3>
                  <p className="text-3xl font-bold text-green-600">Online</p>
                  <p className="text-sm text-gray-500 mt-2">
                    {resolvedThreats} threats resolved • {totalThreats} total threats
                  </p>
                </div>
              </div>

              {/* Quick Actions */}
              <div className="bg-white rounded-lg shadow p-8 mb-8">
                <h2 className="text-2xl font-semibold mb-4">Quick Actions</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Link
                    href="/threats"
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
                  >
                    <h3 className="font-semibold text-gray-900 mb-1">View Threats</h3>
                    <p className="text-sm text-gray-600">Monitor and manage detected threats</p>
                  </Link>

                  <Link
                    href="/documents"
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
                  >
                    <h3 className="font-semibold text-gray-900 mb-1">Upload Documents</h3>
                    <p className="text-sm text-gray-600">Process cybersecurity documents</p>
                  </Link>

                  <Link
                    href="/simulations"
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
                  >
                    <h3 className="font-semibold text-gray-900 mb-1">Run Simulations</h3>
                    <p className="text-sm text-gray-600">Test defensive strategies</p>
                  </Link>

                  <Link
                    href="/analytics"
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
                  >
                    <h3 className="font-semibold text-gray-900 mb-1">View Analytics</h3>
                    <p className="text-sm text-gray-600">Security metrics and reports</p>
                  </Link>

                  <Link
                    href="/learning"
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
                  >
                    <h3 className="font-semibold text-gray-900 mb-1">View Learning</h3>
                    <p className="text-sm text-gray-600">See what the system has learned</p>
                  </Link>
                </div>
              </div>

              {/* Recent Activity */}
              <div className="bg-white rounded-lg shadow p-8">
                <h2 className="text-2xl font-semibold mb-4">Recent Threats</h2>
                {recentThreats.length === 0 ? (
                  <div className="text-center py-8 text-gray-500">
                    <p>No recent threats detected. System is secure.</p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {recentThreats.map((threat) => (
                      <div key={threat.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                        <div>
                          <p className="font-medium text-gray-900">
                            {threat.classification || threat.type || 'Unknown Threat'}
                          </p>
                          <p className="text-sm text-gray-500">
                            {threat.detected_at ? new Date(threat.detected_at).toLocaleString() : 'Unknown time'}
                          </p>
                        </div>
                        <div className="flex items-center gap-3">
                          <span className={`px-3 py-1 rounded text-xs ${
                            threat.severity >= 7 ? 'bg-red-100 text-red-800' :
                            threat.severity >= 4 ? 'bg-yellow-100 text-yellow-800' :
                            'bg-green-100 text-green-800'
                          }`}>
                            Severity: {threat.severity}/10
                          </span>
                          <Link
                            href={`/threats/${threat.id}`}
                            className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                          >
                            View →
                          </Link>
                        </div>
                      </div>
                    ))}
                    <div className="text-center pt-4">
                      <Link href="/threats" className="text-blue-600 hover:text-blue-800 text-sm">
                        View All Threats →
                      </Link>
                    </div>
                  </div>
                )}
              </div>
            </>
          )}
        </main>

        <footer className="bg-white border-t mt-12">
          <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
            <p className="text-center text-gray-600">
              © 2024 SentinelAI X. All rights reserved.
            </p>
          </div>
        </footer>
      </div>
    </>
  )
}
