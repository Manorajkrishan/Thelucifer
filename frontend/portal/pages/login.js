import { useState, useEffect, useCallback } from 'react'
import Head from 'next/head'
import Link from 'next/link'
import { useRouter } from 'next/router'
import axios from 'axios'

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
const api = (path) => `${String(API_BASE).replace(/\/$/, '')}${path}`

export default function Login() {
  const router = useRouter()
  const [form, setForm] = useState({ email: '', password: '' })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [apiReady, setApiReady] = useState(false)
  const [apiChecking, setApiChecking] = useState(true)

  const checkApi = useCallback(async () => {
    setApiChecking(true)
    setError('')
    try {
      const r = await axios.get(api('/api/health'), { timeout: 5000 })
      setApiReady(!!(r?.data?.success && r?.data?.status === 'online'))
    } catch {
      setApiReady(false)
    } finally {
      setApiChecking(false)
    }
  }, [])

  useEffect(() => {
    checkApi()
  }, [checkApi])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const response = await axios.post(api('/api/login'), form, {
        timeout: 15000,
        headers: { 'Content-Type': 'application/json' },
      })
      
      if (response.data.success) {
        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
        router.push('/dashboard')
        return
      }
      setError('Login failed. Invalid response.')
    } catch (err) {
      if (err.code === 'ECONNABORTED' || err.message?.includes('timeout')) {
        setError('Request timed out. Is the Laravel API running? Run .\\FIX-PORT-8000-AND-START-API.ps1 then restart the Portal.')
      } else if (err.response?.status === 404) {
        setError('API not found. Run .\\FIX-PORT-8000-AND-START-API.ps1 (or start Laravel on 8000), then restart the Portal.')
      } else if (err.response?.status === 401) {
        setError(err.response?.data?.message || 'Invalid email or password.')
      } else if (err.response?.data?.message) {
        setError(err.response.data.message)
      } else if (err.request && !err.response) {
        setError('Cannot reach API. Start Laravel (FIX-PORT-8000-AND-START-API.ps1) and the Portal (npm run dev).')
      } else {
        setError(err.message || 'Login failed. Check the API is running.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <Head>
        <title>Login - SentinelAI X</title>
        <meta name="description" content="Login to SentinelAI X" />
      </Head>

      <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">SentinelAI X</h1>
          <p className="text-gray-600">Sign in to your account</p>
          <div className="mt-3 text-sm">
            {apiChecking ? (
              <span className="text-gray-500">Checking API…</span>
            ) : apiReady ? (
              <span className="text-green-600">API ✓ Ready</span>
            ) : (
              <span className="text-amber-600">
                API ✗ Not reachable. Run FIX-PORT-8000-AND-START-API.ps1, then{' '}
                <button type="button" onClick={checkApi} className="underline font-medium text-amber-700 hover:text-amber-800">
                  Retry
                </button>
              </span>
            )}
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Email
            </label>
            <input
              type="email"
              required
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="admin@sentinelai.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Password
            </label>
            <input
              type="password"
              required
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="••••••••"
            />
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading || apiChecking}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed font-semibold"
          >
            {loading ? 'Logging in...' : apiChecking ? 'Checking...' : 'Login'}
          </button>
        </form>

        <div className="mt-6 text-center text-sm text-gray-600">
          <p>Default credentials:</p>
          <p className="font-mono text-xs mt-2">
            Email: admin@sentinelai.com<br />
            Password: admin123
          </p>
        </div>

        <div className="mt-6 text-center">
          <Link href="/" prefetch={false} className="text-blue-600 hover:text-blue-700 text-sm">
            ← Back to Home
          </Link>
        </div>
      </div>
    </div>
  )
}
