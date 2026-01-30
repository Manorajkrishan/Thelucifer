import { useState, useEffect } from 'react'
import Head from 'next/head'
import Link from 'next/link'
import { useRouter } from 'next/router'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default function Threats() {
  const router = useRouter()
  const [threats, setThreats] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [token, setToken] = useState(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')
  const [filterSeverity, setFilterSeverity] = useState('all')
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [newThreat, setNewThreat] = useState({
    type: '',
    severity: 5,
    source_ip: '',
    target_ip: '',
    description: '',
    classification: ''
  })

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (storedToken) {
      fetchThreats(storedToken)
    } else {
      setLoading(false)
      setError('Please login to view threats')
    }
  }, [filterStatus, filterSeverity, searchTerm])

  const fetchThreats = async (authToken) => {
    try {
      setLoading(true)
      let url = `${API_URL}/api/threats?per_page=50`
      if (filterStatus !== 'all') {
        url += `&status=${filterStatus}`
      }
      if (filterSeverity !== 'all') {
        url += `&severity=${filterSeverity}`
      }
      if (searchTerm) {
        url += `&search=${encodeURIComponent(searchTerm)}`
      }

      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error('Failed to fetch threats')
      }

      const data = await response.json()
      let threatsArray = []
      if (data.success && data.data) {
        if (data.data.data && Array.isArray(data.data.data)) {
          threatsArray = data.data.data
        } else if (Array.isArray(data.data)) {
          threatsArray = data.data
        }
      } else if (Array.isArray(data)) {
        threatsArray = data
      } else if (data.threats && Array.isArray(data.threats)) {
        threatsArray = data.threats
      }
      
      if (!Array.isArray(threatsArray)) {
        threatsArray = []
      }
      
      setThreats(threatsArray)
      setError(null)
    } catch (err) {
      setError(err.message)
      setThreats([])
    } finally {
      setLoading(false)
    }
  }

  const handleCreateThreat = async (e) => {
    e.preventDefault()
    if (!token) return

    try {
      setError(null)
      const response = await fetch(`${API_URL}/api/threats`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(newThreat)
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.message || 'Failed to create threat')
      }

      setShowCreateModal(false)
      setNewThreat({
        type: '',
        severity: 5,
        source_ip: '',
        target_ip: '',
        description: '',
        classification: ''
      })
      fetchThreats(token)
    } catch (err) {
      setError(err.message || 'Failed to create threat')
    }
  }

  const handleUpdateStatus = async (threat, newStatus) => {
    if (!token) return

    try {
      setError(null)
      const response = await fetch(`${API_URL}/api/threats/${threat.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ status: newStatus })
      })

      if (!response.ok) {
        throw new Error('Failed to update threat')
      }

      fetchThreats(token)
    } catch (err) {
      setError(err.message || 'Failed to update threat')
    }
  }

  const handleDelete = async (threat) => {
    if (!token) return
    if (!confirm(`Are you sure you want to delete this threat?`)) return

    try {
      setError(null)
      const response = await fetch(`${API_URL}/api/threats/${threat.id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (!response.ok) {
        throw new Error('Failed to delete threat')
      }

      fetchThreats(token)
    } catch (err) {
      setError(err.message || 'Failed to delete threat')
    }
  }

  return (
    <>
      <Head>
        <title>Threats - SentinelAI X</title>
        <meta name="description" content="View and manage cybersecurity threats" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold text-gray-900">Threats</h1>
              <div className="flex gap-4">
                <Link href="/dashboard" className="text-blue-600 hover:text-blue-800">
                  Dashboard
                </Link>
                <Link href="/documents" className="text-gray-600 hover:text-gray-800">
                  Documents
                </Link>
                <Link href="/simulations" className="text-gray-600 hover:text-gray-800">
                  Simulations
                </Link>
                <Link href="/analytics" className="text-gray-600 hover:text-gray-800">
                  Analytics
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
              <p className="text-yellow-800 mb-4">Please login to view threats</p>
              <Link href="/login" prefetch={false} className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Go to Login
              </Link>
            </div>
          ) : (
            <div className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800">{error}</p>
                </div>
              )}

              {/* Actions Bar */}
              <div className="flex justify-between items-center">
                <button
                  onClick={() => setShowCreateModal(true)}
                  className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
                >
                  + Create Threat
                </button>
                <button
                  onClick={() => fetchThreats(token)}
                  className="text-sm text-blue-600 hover:text-blue-800"
                >
                  Refresh
                </button>
              </div>

              {/* Filters */}
              <div className="bg-white rounded-lg shadow p-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <input
                    type="text"
                    placeholder="Search threats..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  />
                  <select
                    value={filterStatus}
                    onChange={(e) => setFilterStatus(e.target.value)}
                    className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="all">All Status</option>
                    <option value="detected">Detected</option>
                    <option value="analyzing">Analyzing</option>
                    <option value="mitigated">Mitigated</option>
                    <option value="resolved">Resolved</option>
                  </select>
                  <select
                    value={filterSeverity}
                    onChange={(e) => setFilterSeverity(e.target.value)}
                    className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="all">All Severity</option>
                    <option value="1">Severity 1-3 (Low)</option>
                    <option value="4">Severity 4-6 (Medium)</option>
                    <option value="7">Severity 7-10 (High)</option>
                  </select>
                </div>
              </div>

              {/* Threats List */}
              {loading ? (
                <div className="text-center py-12">
                  <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                  <p className="mt-4 text-gray-600">Loading threats...</p>
                </div>
              ) : (
                <div className="bg-white rounded-lg shadow">
                  <div className="px-6 py-4 border-b border-gray-200">
                    <h2 className="text-xl font-semibold">Detected Threats ({threats.length})</h2>
                  </div>
                  <div className="divide-y divide-gray-200">
                    {!Array.isArray(threats) || threats.length === 0 ? (
                      <div className="px-6 py-12 text-center text-gray-500">
                        <p>No threats detected. System is secure.</p>
                      </div>
                    ) : (
                      threats.map((threat) => (
                        <div key={threat.id} className="px-6 py-4 hover:bg-gray-50">
                          <div className="flex justify-between items-start">
                            <div className="flex-1">
                              <div className="flex items-center gap-3">
                                <h3 className="text-lg font-medium text-gray-900">
                                  {threat.classification || threat.type || 'Unknown Threat'}
                                </h3>
                                <span className={`px-2 py-1 rounded text-xs ${
                                  threat.status === 'resolved' ? 'bg-green-100 text-green-800' :
                                  threat.status === 'mitigated' ? 'bg-blue-100 text-blue-800' :
                                  threat.status === 'analyzing' ? 'bg-yellow-100 text-yellow-800' :
                                  'bg-red-100 text-red-800'
                                }`}>
                                  {threat.status || 'detected'}
                                </span>
                              </div>
                              <p className="text-sm text-gray-500 mt-1">
                                {threat.description || 'No description available'}
                              </p>
                              <div className="flex gap-4 mt-2 text-sm">
                                <span className={`px-2 py-1 rounded ${
                                  threat.severity >= 7 ? 'bg-red-100 text-red-800' :
                                  threat.severity >= 4 ? 'bg-yellow-100 text-yellow-800' :
                                  'bg-green-100 text-green-800'
                                }`}>
                                  Severity: {threat.severity || 'N/A'}/10
                                </span>
                                {threat.source_ip && (
                                  <span className="text-gray-600">Source: {threat.source_ip}</span>
                                )}
                                {threat.target_ip && (
                                  <span className="text-gray-600">Target: {threat.target_ip}</span>
                                )}
                                {threat.detected_at && (
                                  <span className="text-gray-600">
                                    {new Date(threat.detected_at).toLocaleString()}
                                  </span>
                                )}
                              </div>
                            </div>
                            <div className="flex gap-2 ml-4">
                              <Link
                                href={`/threats/${threat.id}`}
                                className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                              >
                                View
                              </Link>
                              <select
                                value={threat.status || 'detected'}
                                onChange={(e) => handleUpdateStatus(threat, e.target.value)}
                                className="text-sm border border-gray-300 rounded px-2 py-1"
                              >
                                <option value="detected">Detected</option>
                                <option value="analyzing">Analyzing</option>
                                <option value="mitigated">Mitigated</option>
                                <option value="resolved">Resolved</option>
                              </select>
                              <button
                                onClick={() => handleDelete(threat)}
                                className="text-red-600 hover:text-red-800 text-sm font-medium"
                              >
                                Delete
                              </button>
                            </div>
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Create Threat Modal */}
          {showCreateModal && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-white rounded-lg p-6 max-w-md w-full">
                <h2 className="text-xl font-semibold mb-4">Create New Threat</h2>
                <form onSubmit={handleCreateThreat} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Type *</label>
                    <input
                      type="text"
                      value={newThreat.type}
                      onChange={(e) => setNewThreat({...newThreat, type: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Severity (1-10) *</label>
                    <input
                      type="number"
                      min="1"
                      max="10"
                      value={newThreat.severity}
                      onChange={(e) => setNewThreat({...newThreat, severity: parseInt(e.target.value)})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Source IP</label>
                    <input
                      type="text"
                      value={newThreat.source_ip}
                      onChange={(e) => setNewThreat({...newThreat, source_ip: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Target IP</label>
                    <input
                      type="text"
                      value={newThreat.target_ip}
                      onChange={(e) => setNewThreat({...newThreat, target_ip: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Description *</label>
                    <textarea
                      value={newThreat.description}
                      onChange={(e) => setNewThreat({...newThreat, description: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                      rows="3"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Classification</label>
                    <input
                      type="text"
                      value={newThreat.classification}
                      onChange={(e) => setNewThreat({...newThreat, classification: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div className="flex gap-3">
                    <button
                      type="submit"
                      className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                    >
                      Create
                    </button>
                    <button
                      type="button"
                      onClick={() => setShowCreateModal(false)}
                      className="flex-1 bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            </div>
          )}
        </main>
      </div>
    </>
  )
}
