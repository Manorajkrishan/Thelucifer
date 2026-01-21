import { defineStore } from 'pinia'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token'),
    isAuthenticated: false
  }),

  actions: {
    async login(credentials) {
      try {
        const response = await axios.post(`${API_URL}/api/login`, credentials)
        
        if (response.data.token) {
          this.token = response.data.token
          this.user = response.data.user
          this.isAuthenticated = true
          
          localStorage.setItem('token', this.token)
          
          // Set default authorization header
          axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
          
          return { success: true }
        }
        
        return { success: false, error: 'Invalid credentials' }
      } catch (error) {
        return { success: false, error: error.response?.data?.message || 'Login failed' }
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
