/** @type {import('next').NextConfig} */
const apiBase = process.env.NEXT_PUBLIC_API_BACKEND || 'http://localhost:8000'
const nextConfig = {
  reactStrictMode: true,
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || apiBase,
  },
  // No rewrites – frontend calls API directly (CORS on Laravel)
}

module.exports = nextConfig
