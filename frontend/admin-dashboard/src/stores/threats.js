import { defineStore } from 'pinia'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

export const useThreatsStore = defineStore('threats', {
  state: () => ({
    threats: [],
    currentThreat: null,
    statistics: null,
    loading: false,
    error: null
  }),

  actions: {
    async fetchThreats(params = {}) {
      this.loading = true
      this.error = null
      
      try {
        const response = await axios.get(`${API_URL}/api/threats`, { params })
        this.threats = response.data.data?.data || response.data.data || []
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to fetch threats'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async fetchThreat(id) {
      this.loading = true
      this.error = null
      
      try {
        const response = await axios.get(`${API_URL}/api/threats/${id}`)
        this.currentThreat = response.data.data
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to fetch threat'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async fetchStatistics() {
      try {
        const response = await axios.get(`${API_URL}/api/threats/statistics`)
        this.statistics = response.data.data
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to fetch statistics'
        return { success: false }
      }
    },

    async updateThreat(id, data) {
      try {
        const response = await axios.put(`${API_URL}/api/threats/${id}`, data)
        const updatedThreat = response.data.data
        
        // Update in list
        const index = this.threats.findIndex(t => t.id === id)
        if (index !== -1) {
          this.threats[index] = updatedThreat
        }
        
        if (this.currentThreat?.id === id) {
          this.currentThreat = updatedThreat
        }
        
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to update threat'
        return { success: false, error: this.error }
      }
    }
  }
})
