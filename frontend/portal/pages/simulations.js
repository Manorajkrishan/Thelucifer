import { useState, useEffect } from 'react'
import Head from 'next/head'
import Link from 'next/link'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
const ML_SERVICE_URL = process.env.NEXT_PUBLIC_ML_SERVICE_URL || 'http://localhost:5000'

export default function Simulations() {
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)
  const [simulationResult, setSimulationResult] = useState(null)
  const [counterOffensiveResult, setCounterOffensiveResult] = useState(null)
  const [threats, setThreats] = useState([])
  const [selectedThreat, setSelectedThreat] = useState(null)
  const [simulationType, setSimulationType] = useState('defensive')
  const [attackData, setAttackData] = useState({
    source_ip: '',
    target_ip: '',
    attack_type: '',
    description: ''
  })

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (storedToken) {
      fetchThreats(storedToken)
    }
  }, [])

  const fetchThreats = async (authToken) => {
    try {
      const response = await fetch(`${API_URL}/api/threats?per_page=10`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (handleUnauthorized(response)) return
      if (response.ok) {
        const data = await response.json()
        let threatsArray = []
        if (data.success && data.data?.data) {
          threatsArray = data.data.data
        } else if (Array.isArray(data.data)) {
          threatsArray = data.data
        }
        setThreats(Array.isArray(threatsArray) ? threatsArray : [])
      }
    } catch (err) {
      console.error('Failed to fetch threats:', err)
    }
  }

  const handleRunSimulation = async (e) => {
    e.preventDefault()
    if (!token) {
      setError('Please login to run simulations')
      return
    }

    try {
      setLoading(true)
      setError(null)
      setSuccess(null)
      setSimulationResult(null)

      const response = await fetch(`${ML_SERVICE_URL}/api/v1/simulations/run`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          type: simulationType,
          threat_data: selectedThreat || attackData
        })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Simulation failed')
      }

      setSimulationResult(data.simulation)
      setSuccess('Simulation completed successfully!')
    } catch (err) {
      setError(err.message || 'Failed to run simulation')
    } finally {
      setLoading(false)
    }
  }

  const handleCounterOffensive = async (e) => {
    e.preventDefault()
    if (!token) {
      setError('Please login to run counter-offensive simulations')
      return
    }

    if (!confirm('⚠️ WARNING: This will simulate a counter-offensive response. This is for educational/simulation purposes only. Continue?')) {
      return
    }

    try {
      setLoading(true)
      setError(null)
      setSuccess(null)
      setCounterOffensiveResult(null)

      const response = await fetch(`${ML_SERVICE_URL}/api/v1/counter-offensive/execute`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          attack_data: selectedThreat || attackData
        })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Counter-offensive simulation failed')
      }

      setCounterOffensiveResult(data)
      setSuccess('Counter-offensive simulation completed!')
    } catch (err) {
      setError(err.message || 'Failed to run counter-offensive simulation')
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <Head>
        <title>Simulations - SentinelAI X</title>
        <meta name="description" content="Run cyber-offensive simulations" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold text-gray-900">Simulations</h1>
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
              <p className="text-yellow-800 mb-4">Please login to run simulations</p>
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
              {success && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-green-800">{success}</p>
                </div>
              )}

              {/* Threat Selection */}
              {threats.length > 0 && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-xl font-semibold mb-4">Select Threat for Simulation</h2>
                  <select
                    value={selectedThreat?.id || ''}
                    onChange={(e) => {
                      const threat = threats.find(t => t.id === parseInt(e.target.value))
                      setSelectedThreat(threat)
                      if (threat) {
                        setAttackData({
                          source_ip: threat.source_ip || '',
                          target_ip: threat.target_ip || '',
                          attack_type: threat.type || '',
                          description: threat.description || ''
                        })
                      }
                    }}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  >
                    <option value="">Select a threat...</option>
                    {threats.map((threat) => (
                      <option key={threat.id} value={threat.id}>
                        {threat.classification || threat.type} - Severity: {threat.severity}
                      </option>
                    ))}
                  </select>
                </div>
              )}

              {/* Defensive Simulation */}
              <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-xl font-semibold mb-4">Defensive Simulation</h2>
                <p className="text-gray-600 mb-4">
                  Run simulated attack scenarios in sandboxed environments to test defensive capabilities.
                </p>
                <form onSubmit={handleRunSimulation} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Simulation Type</label>
                    <select
                      value={simulationType}
                      onChange={(e) => setSimulationType(e.target.value)}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                    >
                      <option value="defensive">Defensive Strategy</option>
                      <option value="offensive">Offensive Strategy</option>
                      <option value="mitigation">Mitigation Test</option>
                      <option value="response">Response Time Test</option>
                    </select>
                  </div>
                  {!selectedThreat && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Source IP</label>
                        <input
                          type="text"
                          value={attackData.source_ip}
                          onChange={(e) => setAttackData({...attackData, source_ip: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                          placeholder="192.168.1.100"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Target IP</label>
                        <input
                          type="text"
                          value={attackData.target_ip}
                          onChange={(e) => setAttackData({...attackData, target_ip: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                          placeholder="192.168.1.1"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Attack Type</label>
                        <input
                          type="text"
                          value={attackData.attack_type}
                          onChange={(e) => setAttackData({...attackData, attack_type: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                          placeholder="DDoS, Malware, etc."
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
                        <textarea
                          value={attackData.description}
                          onChange={(e) => setAttackData({...attackData, description: e.target.value})}
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                          rows="3"
                          placeholder="Attack description..."
                        />
                      </div>
                    </>
                  )}
                  <button
                    type="submit"
                    disabled={loading}
                    className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                  >
                    {loading ? 'Running Simulation...' : 'Run Simulation'}
                  </button>
                </form>

                {simulationResult && (
                  <div className="mt-6 bg-gray-50 rounded-lg p-4">
                    <h3 className="font-semibold mb-2">Simulation Results:</h3>
                    <pre className="text-sm overflow-auto">
                      {JSON.stringify(simulationResult, null, 2)}
                    </pre>
                  </div>
                )}
              </div>

              {/* Counter-Offensive Simulation */}
              <div className="bg-white rounded-lg shadow p-6 border-2 border-orange-200">
                <div className="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-4">
                  <p className="text-orange-800 font-semibold">⚠️ SIMULATION ONLY</p>
                  <p className="text-orange-700 text-sm mt-1">
                    This is a fictional counter-offensive simulation system for educational purposes only. 
                    No actual attacks are executed.
                  </p>
                </div>
                <h2 className="text-xl font-semibold mb-4">Autonomous Cyber Counter-Offensive (Simulated)</h2>
                <p className="text-gray-600 mb-4">
                  Simulate the full counter-offensive cycle: Detection → Profiling → Validation → Counter-Attack (SIMULATED)
                </p>
                <form onSubmit={handleCounterOffensive} className="space-y-4">
                  <button
                    type="submit"
                    disabled={loading}
                    className="bg-orange-600 text-white px-6 py-2 rounded-lg hover:bg-orange-700 disabled:opacity-50"
                  >
                    {loading ? 'Executing...' : 'Execute Counter-Offensive Simulation'}
                  </button>
                </form>

                {counterOffensiveResult && (
                  <div className="mt-6 space-y-4">
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h3 className="font-semibold mb-2">Attacker Profile:</h3>
                      <pre className="text-sm overflow-auto">
                        {JSON.stringify(counterOffensiveResult.attacker_profile, null, 2)}
                      </pre>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h3 className="font-semibold mb-2">Validation Result:</h3>
                      <pre className="text-sm overflow-auto">
                        {JSON.stringify(counterOffensiveResult.validation, null, 2)}
                      </pre>
                    </div>
                    {counterOffensiveResult.counter_offensive && (
                      <div className="bg-gray-50 rounded-lg p-4">
                        <h3 className="font-semibold mb-2">Counter-Offensive Result (SIMULATED):</h3>
                        <pre className="text-sm overflow-auto">
                          {JSON.stringify(counterOffensiveResult.counter_offensive, null, 2)}
                        </pre>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          )}
        </main>
      </div>
    </>
  )
}
