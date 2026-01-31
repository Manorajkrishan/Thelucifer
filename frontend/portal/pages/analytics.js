import { useState, useEffect } from 'react'
import Head from 'next/head'
import Link from 'next/link'
import { handleUnauthorized } from '../lib/api'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default function Analytics() {
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [stats, setStats] = useState(null)
  const [threats, setThreats] = useState([])
  const [documents, setDocuments] = useState([])

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (storedToken) {
      fetchAllData(storedToken)
    } else {
      setLoading(false)
    }
  }, [])

  const fetchAllData = async (authToken) => {
    try {
      setLoading(true)
      
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
      const threatsResponse = await fetch(`${API_URL}/api/threats?per_page=10`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (handleUnauthorized(threatsResponse)) return
      if (threatsResponse.ok) {
        const threatsData = await threatsResponse.json()
        let threatsArray = []
        if (threatsData.success && threatsData.data?.data) {
          threatsArray = threatsData.data.data
        } else if (Array.isArray(threatsData.data)) {
          threatsArray = threatsData.data
        }
        setThreats(Array.isArray(threatsArray) ? threatsArray : [])
      }

      // Fetch documents count
      const docsResponse = await fetch(`${API_URL}/api/documents?per_page=1`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (handleUnauthorized(docsResponse)) return
      if (docsResponse.ok) {
        const docsData = await docsResponse.json()
        if (docsData.success && docsData.data) {
          const totalDocs = docsData.data.total || docsData.data.data?.length || 0
          setDocuments([{ total: totalDocs }])
        }
      }

      setError(null)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const getSeverityColor = (severity) => {
    if (severity >= 7) return 'bg-red-500'
    if (severity >= 4) return 'bg-yellow-500'
    return 'bg-green-500'
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'resolved': return 'bg-green-500'
      case 'mitigated': return 'bg-blue-500'
      case 'analyzing': return 'bg-yellow-500'
      default: return 'bg-red-500'
    }
  }

  return (
    <>
      <Head>
        <title>Analytics - SentinelAI X</title>
        <meta name="description" content="Security metrics and analytics" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
              <div className="flex gap-4">
                <Link href="/dashboard" className="text-blue-600 hover:text-blue-800">
                  Dashboard
                </Link>
                <Link href="/threats" className="text-gray-600 hover:text-gray-800">
                  Threats
                </Link>
                <Link href="/documents" className="text-gray-600 hover:text-gray-800">
                  Documents
                </Link>
                <Link href="/simulations" className="text-gray-600 hover:text-gray-800">
                  Simulations
                </Link>
                <Link href="/learning" className="text-gray-600 hover:text-gray-800">
                  Learning
                </Link>
              </div>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {!token ? (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
              <p className="text-yellow-800 mb-4">Please login to view analytics</p>
              <Link href="/login" prefetch={false} className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Go to Login
              </Link>
            </div>
          ) : loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Loading analytics...</p>
            </div>
          ) : error ? (
            <div className="bg-red-50 border border-red-200 rounded-lg p-6">
              <p className="text-red-800">{error}</p>
            </div>
          ) : (
            <div className="space-y-6">
              {/* Overview Cards */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Total Threats</h3>
                  <p className="text-3xl font-bold text-gray-900">{stats?.total || 0}</p>
                  <p className="text-sm text-gray-500 mt-2">Last 24h: {stats?.recent_24h || 0}</p>
                </div>
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Documents</h3>
                  <p className="text-3xl font-bold text-blue-600">{documents[0]?.total || 0}</p>
                  <p className="text-sm text-gray-500 mt-2">Total processed</p>
                </div>
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Active Threats</h3>
                  <p className="text-3xl font-bold text-red-600">
                    {(stats?.by_status?.detected || 0) + (stats?.by_status?.analyzing || 0)}
                  </p>
                  <p className="text-sm text-gray-500 mt-2">Detected + Analyzing</p>
                </div>
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Resolved</h3>
                  <p className="text-3xl font-bold text-green-600">{stats?.by_status?.resolved || 0}</p>
                  <p className="text-sm text-gray-500 mt-2">Successfully resolved</p>
                </div>
              </div>

              {/* Threat Status Distribution */}
              {stats?.by_status && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-xl font-semibold mb-4">Threat Status Distribution</h2>
                  <div className="space-y-4">
                    {Object.entries(stats.by_status).map(([status, count]) => (
                      <div key={status}>
                        <div className="flex justify-between items-center mb-2">
                          <span className="text-sm font-medium text-gray-700 capitalize">{status}</span>
                          <span className="text-sm text-gray-600">{count}</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className={`h-2 rounded-full ${getStatusColor(status)}`}
                            style={{ width: `${(count / stats.total) * 100}%` }}
                          ></div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Threat Type Distribution */}
              {stats?.by_type && Object.keys(stats.by_type).length > 0 && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-xl font-semibold mb-4">Threat Type Distribution</h2>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {Object.entries(stats.by_type).map(([type, count]) => (
                      <div key={type} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <span className="text-sm font-medium text-gray-700">{type || 'Unknown'}</span>
                        <span className="text-lg font-bold text-gray-900">{count}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Severity Distribution */}
              {stats?.by_severity && Object.keys(stats.by_severity).length > 0 && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-xl font-semibold mb-4">Severity Distribution</h2>
                  <div className="space-y-3">
                    {Object.entries(stats.by_severity)
                      .sort((a, b) => parseInt(a[0]) - parseInt(b[0]))
                      .map(([severity, count]) => (
                        <div key={severity}>
                          <div className="flex justify-between items-center mb-2">
                            <span className="text-sm font-medium text-gray-700">
                              Severity {severity}/10
                            </span>
                            <span className="text-sm text-gray-600">{count}</span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-2">
                            <div
                              className={`h-2 rounded-full ${getSeverityColor(parseInt(severity))}`}
                              style={{ width: `${(count / stats.total) * 100}%` }}
                            ></div>
                          </div>
                        </div>
                      ))}
                  </div>
                </div>
              )}

              {/* Recent Threats */}
              {threats.length > 0 && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-xl font-semibold mb-4">Recent Threats</h2>
                  <div className="space-y-3">
                    {threats.slice(0, 5).map((threat) => (
                      <div key={threat.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div className="flex-1">
                          <p className="font-medium text-gray-900">
                            {threat.classification || threat.type || 'Unknown'}
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
                          <span className={`px-3 py-1 rounded text-xs ${
                            threat.status === 'resolved' ? 'bg-green-100 text-green-800' :
                            threat.status === 'mitigated' ? 'bg-blue-100 text-blue-800' :
                            threat.status === 'analyzing' ? 'bg-yellow-100 text-yellow-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                            {threat.status || 'detected'}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                  <div className="mt-4 text-center">
                    <Link href="/threats" className="text-blue-600 hover:text-blue-800 text-sm">
                      View All Threats →
                    </Link>
                  </div>
                </div>
              )}
            </div>
          )}
        </main>
      </div>
    </>
  )
}
