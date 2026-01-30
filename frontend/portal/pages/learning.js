import { useState, useEffect } from 'react'
import Head from 'next/head'
import Link from 'next/link'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
const ML_SERVICE_URL = process.env.NEXT_PUBLIC_ML_SERVICE_URL || 'http://localhost:5000'

export default function Learning() {
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [summary, setSummary] = useState(null)
  const [knowledgeQuery, setKnowledgeQuery] = useState('')
  const [knowledgeResults, setKnowledgeResults] = useState([])
  const [querying, setQuerying] = useState(false)
  const [attackTechniques, setAttackTechniques] = useState([])
  const [defenseStrategies, setDefenseStrategies] = useState([])

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (storedToken) {
      fetchLearningSummary()
      fetchAttackTechniques()
      fetchDefenseStrategies()
    } else {
      setLoading(false)
    }
  }, [])

  const fetchLearningSummary = async () => {
    try {
      setLoading(true)
      const response = await fetch(`${ML_SERVICE_URL}/api/v1/learning/summary`)

      if (!response.ok) {
        throw new Error('Failed to fetch learning summary')
      }

      const data = await response.json()
      setSummary(data.summary || data)
      setError(null)
    } catch (err) {
      setError(err.message)
      setSummary(null)
    } finally {
      setLoading(false)
    }
  }

  const fetchAttackTechniques = async () => {
    try {
      const response = await fetch(`${ML_SERVICE_URL}/api/v1/knowledge/query?query=attack technique`)
      if (response.ok) {
        const data = await response.json()
        setAttackTechniques(data.results || [])
      }
    } catch (err) {
      console.error('Failed to fetch attack techniques:', err)
    }
  }

  const fetchDefenseStrategies = async () => {
    try {
      const response = await fetch(`${ML_SERVICE_URL}/api/v1/knowledge/query?query=defense strategy`)
      if (response.ok) {
        const data = await response.json()
        setDefenseStrategies(data.results || [])
      }
    } catch (err) {
      console.error('Failed to fetch defense strategies:', err)
    }
  }

  const handleKnowledgeQuery = async (e) => {
    e.preventDefault()
    if (!knowledgeQuery.trim()) return

    try {
      setQuerying(true)
      setError(null)

      const response = await fetch(`${ML_SERVICE_URL}/api/v1/knowledge/query?query=${encodeURIComponent(knowledgeQuery)}`)

      if (!response.ok) {
        throw new Error('Failed to query knowledge graph')
      }

      const data = await response.json()
      setKnowledgeResults(data.results || [])
    } catch (err) {
      setError(err.message)
      setKnowledgeResults([])
    } finally {
      setQuerying(false)
    }
  }

  return (
    <>
      <Head>
        <title>Learning & Knowledge - SentinelAI X</title>
        <meta name="description" content="View what the system has learned" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold text-gray-900">Learning & Knowledge</h1>
              <div className="flex gap-4">
                <Link href="/dashboard" className="text-blue-600 hover:text-blue-800">
                  Dashboard
                </Link>
                <Link href="/documents" className="text-gray-600 hover:text-gray-800">
                  Documents
                </Link>
                <Link href="/threats" className="text-gray-600 hover:text-gray-800">
                  Threats
                </Link>
                <Link href="/analytics" className="text-gray-600 hover:text-gray-800">
                  Analytics
                </Link>
              </div>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {!token ? (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
              <p className="text-yellow-800 mb-4">Please login to view learning data</p>
              <Link href="/login" prefetch={false} className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Go to Login
              </Link>
            </div>
          ) : loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Loading learning data...</p>
            </div>
          ) : (
            <div className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800">{error}</p>
                </div>
              )}

              {/* Learning Summary */}
              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-2xl font-semibold">Learning Summary</h2>
                  <button
                    onClick={fetchLearningSummary}
                    className="text-sm text-blue-600 hover:text-blue-800"
                  >
                    Refresh
                  </button>
                </div>
                
                {summary && (summary.total_documents === 0 && summary.total_patterns_learned === 0) ? (
                  <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
                    <div className="text-4xl mb-4">📚</div>
                    <h3 className="text-lg font-semibold text-yellow-900 mb-2">No Learning Data Yet</h3>
                    <p className="text-yellow-800 mb-4">
                      The system hasn't processed any documents yet. Process your documents to start learning!
                    </p>
                    <div className="space-y-2 text-sm text-yellow-700 text-left max-w-md mx-auto">
                      <p className="font-semibold">To start learning:</p>
                      <ol className="list-decimal list-inside space-y-1">
                        <li>Go to <Link href="/documents" className="text-blue-600 hover:underline">Documents page</Link></li>
                        <li>Upload documents or use Google Drive links</li>
                        <li>Click "Process" on each document</li>
                        <li>Come back here to see what was learned!</li>
                      </ol>
                    </div>
                  </div>
                ) : summary ? (
                  <>
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                      <div className="bg-blue-50 rounded-lg p-4">
                        <h3 className="text-sm font-medium text-gray-600 mb-1">Documents Processed</h3>
                        <p className="text-3xl font-bold text-blue-600">{summary.total_documents || 0}</p>
                      </div>
                      
                      <div className="bg-green-50 rounded-lg p-4">
                        <h3 className="text-sm font-medium text-gray-600 mb-1">Patterns Learned</h3>
                        <p className="text-3xl font-bold text-green-600">{summary.total_patterns_learned || 0}</p>
                      </div>
                      
                      <div className="bg-red-50 rounded-lg p-4">
                        <h3 className="text-sm font-medium text-gray-600 mb-1">Attack Techniques</h3>
                        <p className="text-3xl font-bold text-red-600">{summary.unique_attack_techniques || 0}</p>
                      </div>
                      
                      <div className="bg-purple-50 rounded-lg p-4">
                        <h3 className="text-sm font-medium text-gray-600 mb-1">Exploit Patterns</h3>
                        <p className="text-3xl font-bold text-purple-600">{summary.unique_exploit_patterns || 0}</p>
                      </div>
                    </div>

                  {/* Attack Techniques List */}
                  {summary.attack_techniques && summary.attack_techniques.length > 0 && (
                    <div className="mt-6">
                      <h3 className="text-lg font-semibold mb-3">Learned Attack Techniques</h3>
                      <div className="flex flex-wrap gap-2">
                        {summary.attack_techniques.map((technique, idx) => (
                          <span
                            key={idx}
                            className="px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm"
                          >
                            {technique}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Exploit Patterns List */}
                  {summary.exploit_patterns && summary.exploit_patterns.length > 0 && (
                    <div className="mt-6">
                      <h3 className="text-lg font-semibold mb-3">Learned Exploit Patterns</h3>
                      <div className="flex flex-wrap gap-2">
                        {summary.exploit_patterns.map((pattern, idx) => (
                          <span
                            key={idx}
                            className="px-3 py-1 bg-purple-100 text-purple-800 rounded-full text-sm"
                          >
                            {pattern}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}
                  </>
                ) : (
                  <div className="text-center py-8 text-gray-500">
                    <p>Loading learning summary...</p>
                  </div>
                )}
              </div>

              {/* Knowledge Graph Query */}
              <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-2xl font-semibold mb-4">Query Knowledge Graph</h2>
                <form onSubmit={handleKnowledgeQuery} className="space-y-4">
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={knowledgeQuery}
                      onChange={(e) => setKnowledgeQuery(e.target.value)}
                      placeholder="Search for attack techniques, defense strategies, exploit patterns..."
                      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    />
                    <button
                      type="submit"
                      disabled={querying}
                      className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                    >
                      {querying ? 'Searching...' : 'Search'}
                    </button>
                  </div>
                </form>

                {knowledgeResults.length > 0 && (
                  <div className="mt-6">
                    <h3 className="text-lg font-semibold mb-3">Search Results ({knowledgeResults.length})</h3>
                    <div className="space-y-3">
                      {knowledgeResults.map((result, idx) => (
                        <div key={idx} className="bg-gray-50 rounded-lg p-4">
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <h4 className="font-semibold text-gray-900">
                                {result.name || result.identifier || 'Unknown'}
                              </h4>
                              {result.description && (
                                <p className="text-sm text-gray-600 mt-1">{result.description}</p>
                              )}
                              {result.labels && result.labels.length > 0 && (
                                <div className="flex gap-2 mt-2">
                                  {result.labels.map((label, labelIdx) => (
                                    <span
                                      key={labelIdx}
                                      className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs"
                                    >
                                      {label}
                                    </span>
                                  ))}
                                </div>
                              )}
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {knowledgeQuery && knowledgeResults.length === 0 && !querying && (
                  <div className="mt-4 text-center text-gray-500">
                    <p>No results found for "{knowledgeQuery}"</p>
                  </div>
                )}
              </div>

              {/* Attack Techniques */}
              {attackTechniques.length > 0 && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-2xl font-semibold mb-4">Attack Techniques in Knowledge Graph</h2>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {attackTechniques.slice(0, 10).map((technique, idx) => (
                      <div key={idx} className="bg-red-50 rounded-lg p-4 border border-red-200">
                        <h3 className="font-semibold text-red-900 mb-2">
                          {technique.name || technique.identifier || 'Unknown Technique'}
                        </h3>
                        {technique.description && (
                          <p className="text-sm text-red-700">{technique.description}</p>
                        )}
                      </div>
                    ))}
                  </div>
                  {attackTechniques.length > 10 && (
                    <p className="mt-4 text-sm text-gray-600 text-center">
                      Showing 10 of {attackTechniques.length} techniques
                    </p>
                  )}
                </div>
              )}

              {/* Defense Strategies */}
              {defenseStrategies.length > 0 && (
                <div className="bg-white rounded-lg shadow p-6">
                  <h2 className="text-2xl font-semibold mb-4">Defense Strategies in Knowledge Graph</h2>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {defenseStrategies.slice(0, 10).map((strategy, idx) => (
                      <div key={idx} className="bg-green-50 rounded-lg p-4 border border-green-200">
                        <h3 className="font-semibold text-green-900 mb-2">
                          {strategy.name || strategy.identifier || 'Unknown Strategy'}
                        </h3>
                        {strategy.description && (
                          <p className="text-sm text-green-700">{strategy.description}</p>
                        )}
                      </div>
                    ))}
                  </div>
                  {defenseStrategies.length > 10 && (
                    <p className="mt-4 text-sm text-gray-600 text-center">
                      Showing 10 of {defenseStrategies.length} strategies
                    </p>
                  )}
                </div>
              )}

              {/* Info Box */}
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-blue-900 mb-2">💡 How the System Learns</h3>
                <ul className="text-sm text-blue-800 space-y-2 list-disc list-inside">
                  <li>Documents uploaded or downloaded from Drive links are automatically processed</li>
                  <li>Attack techniques, exploit patterns, and defense strategies are extracted</li>
                  <li>Knowledge is stored in the knowledge graph for future threat detection</li>
                  <li>The system continuously improves its detection capabilities based on learned patterns</li>
                </ul>
              </div>
            </div>
          )}
        </main>
      </div>
    </>
  )
}
