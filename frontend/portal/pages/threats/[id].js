import { useState, useEffect } from 'react'
import Head from 'next/head'
import Link from 'next/link'
import { useRouter } from 'next/router'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default function ThreatDetail() {
  const router = useRouter()
  const { id } = router.query
  const [threat, setThreat] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [token, setToken] = useState(null)

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (id && storedToken) {
      fetchThreat(storedToken)
    } else if (!storedToken) {
      setLoading(false)
      setError('Please login to view threat details')
    }
  }, [id])

  const fetchThreat = async (authToken) => {
    try {
      setLoading(true)
      const response = await fetch(`${API_URL}/api/threats/${id}`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error('Failed to fetch threat')
      }

      const data = await response.json()
      setThreat(data.data || data)
      setError(null)
    } catch (err) {
      setError(err.message)
      setThreat(null)
    } finally {
      setLoading(false)
    }
  }

  if (!token) {
    return (
      <>
        <Head>
          <title>Threat Details - SentinelAI X</title>
        </Head>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
            <p className="text-yellow-800 mb-4">Please login to view threat details</p>
            <Link href="/login" prefetch={false} className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
              Go to Login
            </Link>
          </div>
        </div>
      </>
    )
  }

  if (loading) {
    return (
      <>
        <Head>
          <title>Threat Details - SentinelAI X</title>
        </Head>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Loading threat details...</p>
          </div>
        </div>
      </>
    )
  }

  if (error || !threat) {
    return (
      <>
        <Head>
          <title>Threat Details - SentinelAI X</title>
        </Head>
        <div className="min-h-screen bg-gray-50">
          <header className="bg-white shadow-sm">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
              <Link href="/threats" className="text-blue-600 hover:text-blue-800">← Back to Threats</Link>
            </div>
          </header>
          <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div className="bg-red-50 border border-red-200 rounded-lg p-6">
              <p className="text-red-800">{error || 'Threat not found'}</p>
            </div>
          </main>
        </div>
      </>
    )
  }

  return (
    <>
      <Head>
        <title>Threat Details - {threat.classification || threat.type} - SentinelAI X</title>
      </Head>

      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <Link href="/threats" className="text-blue-600 hover:text-blue-800">← Back to Threats</Link>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-lg shadow p-6 mb-6">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gray-900 mb-2">
                  {threat.classification || threat.type || 'Unknown Threat'}
                </h1>
                <span className={`inline-block px-3 py-1 rounded text-sm ${
                  threat.status === 'resolved' ? 'bg-green-100 text-green-800' :
                  threat.status === 'mitigated' ? 'bg-blue-100 text-blue-800' :
                  threat.status === 'analyzing' ? 'bg-yellow-100 text-yellow-800' :
                  'bg-red-100 text-red-800'
                }`}>
                  {threat.status || 'detected'}
                </span>
              </div>
              <span className={`px-4 py-2 rounded-lg font-semibold ${
                threat.severity >= 7 ? 'bg-red-100 text-red-800' :
                threat.severity >= 4 ? 'bg-yellow-100 text-yellow-800' :
                'bg-green-100 text-green-800'
              }`}>
                Severity: {threat.severity || 'N/A'}/10
              </span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
              <div>
                <h3 className="text-sm font-medium text-gray-500 mb-2">Description</h3>
                <p className="text-gray-900">{threat.description || 'No description available'}</p>
              </div>

              <div>
                <h3 className="text-sm font-medium text-gray-500 mb-2">Type</h3>
                <p className="text-gray-900">{threat.type || 'Unknown'}</p>
              </div>

              {threat.source_ip && (
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Source IP</h3>
                  <p className="text-gray-900 font-mono">{threat.source_ip}</p>
                </div>
              )}

              {threat.target_ip && (
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Target IP</h3>
                  <p className="text-gray-900 font-mono">{threat.target_ip}</p>
                </div>
              )}

              {threat.detected_at && (
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Detected At</h3>
                  <p className="text-gray-900">{new Date(threat.detected_at).toLocaleString()}</p>
                </div>
              )}

              {threat.resolved_at && (
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Resolved At</h3>
                  <p className="text-gray-900">{new Date(threat.resolved_at).toLocaleString()}</p>
                </div>
              )}

              {threat.confidence && (
                <div>
                  <h3 className="text-sm font-medium text-gray-500 mb-2">Confidence</h3>
                  <p className="text-gray-900">{(threat.confidence * 100).toFixed(0)}%</p>
                </div>
              )}
            </div>

            {threat.metadata && Object.keys(threat.metadata).length > 0 && (
              <div className="mt-6">
                <h3 className="text-sm font-medium text-gray-500 mb-2">Metadata</h3>
                <pre className="bg-gray-50 p-4 rounded-lg text-sm overflow-auto">
                  {JSON.stringify(threat.metadata, null, 2)}
                </pre>
              </div>
            )}

            {threat.incidents && threat.incidents.length > 0 && (
              <div className="mt-6">
                <h3 className="text-lg font-semibold mb-4">Related Incidents</h3>
                <div className="space-y-2">
                  {threat.incidents.map((incident, idx) => (
                    <div key={idx} className="bg-gray-50 p-4 rounded-lg">
                      <p className="font-medium">{incident.type || 'Incident'}</p>
                      <p className="text-sm text-gray-600">{incident.description || 'No description'}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {threat.actions && threat.actions.length > 0 && (
              <div className="mt-6">
                <h3 className="text-lg font-semibold mb-4">Threat Actions</h3>
                <div className="space-y-2">
                  {threat.actions.map((action, idx) => (
                    <div key={idx} className="bg-gray-50 p-4 rounded-lg">
                      <p className="font-medium">{action.action_type || 'Action'}</p>
                      <p className="text-sm text-gray-600">{action.description || 'No description'}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </main>
      </div>
    </>
  )
}
