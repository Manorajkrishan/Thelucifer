import { defineStore } from 'pinia'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

export const useAuthStore = defineStore('auth', {
  state: () => {
    const token = typeof localStorage !== 'undefined' ? localStorage.getItem('token') : null
    return {
      user: null,
      token,
      isAuthenticated: !!token
    }
  },

  actions: {
    async login(credentials) {
      try {
        const response = await axios.post(`${API_URL}/api/login`, credentials)
        
        if (response.data?.token) {
          this.token = response.data.token
          this.user = response.data.user
          this.isAuthenticated = true
          
          localStorage.setItem('token', this.token)
          
          axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
          
          return { success: true }
        }
        
        return { success: false, error: 'Invalid credentials' }
      } catch (err) {
        const status = err.response?.status
        const msg = err.response?.data?.message || err.message || 'Login failed'
        if (status === 401) {
          return {
            success: false,
            error: 'Invalid email or password. If you haven\'t yet, run .\\CREATE-ADMIN-USER.ps1 then use admin@sentinelai.com / admin123.'
          }
        }
        return { success: false, error: msg }
      }
    },

    async logout() {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      
      localStorage.removeItem('token')
      delete axios.defaults.headers.common['Authorization']
    },

    checkAuth() {
      if (this.token) {
        this.isAuthenticated = true
        axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`

        // Verify token is still valid
        axios.get(`${API_URL}/api/user`)
          .then(response => {
            this.user = response.data
          })
          .catch(() => {
            this.logout()
          })
      }
    }
  }
})
