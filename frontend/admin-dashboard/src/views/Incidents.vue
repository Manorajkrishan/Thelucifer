<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Incidents</h1>
      <button
        @click="showCreateModal = true"
        class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
      >
        Create Incident
      </button>
    </div>

    <!-- Search and Filter -->
    <div class="bg-white rounded-lg shadow p-4 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <input
            v-model="searchTerm"
            type="text"
            placeholder="Search incidents..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg"
            @input="fetchIncidents"
          />
        </div>
        <div>
          <select
            v-model="filterStatus"
            @change="fetchIncidents"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg"
          >
            <option value="all">All Status</option>
            <option value="open">Open</option>
            <option value="investigating">Investigating</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>
        </div>
        <div>
          <button
            @click="fetchIncidents"
            class="w-full bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700"
          >
            Refresh
          </button>
        </div>
      </div>
    </div>

    <!-- Incidents List -->
    <div v-if="loading" class="text-center py-12">
      <p class="text-gray-500">Loading incidents...</p>
    </div>

    <div v-else-if="incidents.length === 0" class="bg-white rounded-lg shadow p-12 text-center">
      <p class="text-gray-500 text-lg">No incidents found</p>
    </div>

    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Severity</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="incident in incidents" :key="incident.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">#{{ incident.id }}</td>
            <td class="px-6 py-4">
              <div class="font-medium text-gray-900">{{ incident.title }}</div>
              <div class="text-sm text-gray-500">{{ incident.description?.substring(0, 50) }}...</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span :class="getSeverityClass(incident.severity)">
                {{ incident.severity }}/10
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 text-xs rounded-full" :class="getStatusClass(incident.status)">
                {{ incident.status }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(incident.created_at) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm">
              <button
                @click="viewIncident(incident)"
                class="text-blue-600 hover:text-blue-800 mr-3"
              >
                View
              </button>
              <button
                @click="updateIncidentStatus(incident)"
                class="text-green-600 hover:text-green-800"
              >
                Update
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Create Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-2xl w-full">
        <h3 class="text-xl font-bold mb-4">Create Incident</h3>
        <form @submit.prevent="createIncident" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Title</label>
            <input
              v-model="incidentForm.title"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea
              v-model="incidentForm.description"
              rows="4"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            ></textarea>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Severity (1-10)</label>
              <input
                v-model.number="incidentForm.severity"
                type="number"
                min="1"
                max="10"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select v-model="incidentForm.status" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
                <option value="open">Open</option>
                <option value="investigating">Investigating</option>
                <option value="resolved">Resolved</option>
              </select>
            </div>
          </div>
          <div class="flex gap-2">
            <button
              type="button"
              @click="showCreateModal = false"
              class="flex-1 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="creating"
              class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {{ creating ? 'Creating...' : 'Create Incident' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const authStore = useAuthStore()
const incidents = ref([])
const loading = ref(false)
const creating = ref(false)
const searchTerm = ref('')
const filterStatus = ref('all')
const showCreateModal = ref(false)

const incidentForm = ref({
  title: '',
  description: '',
  severity: 5,
  status: 'open'
})

onMounted(() => {
  fetchIncidents()
})

const fetchIncidents = async () => {
  loading.value = true
  try {
    const params = {}
    if (filterStatus.value !== 'all') {
      params.status = filterStatus.value
    }
    if (searchTerm.value) {
      params.search = searchTerm.value
    }

    const response = await axios.get(`${API_URL}/api/incidents`, {
      params,
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })

    if (response.data.success && response.data.data) {
      incidents.value = response.data.data.data || response.data.data || []
    } else {
      incidents.value = []
    }
  } catch (error) {
    console.error('Failed to fetch incidents:', error)
    incidents.value = []
  } finally {
    loading.value = false
  }
}

const createIncident = async () => {
  creating.value = true
  try {
    await axios.post(`${API_URL}/api/incidents`, incidentForm.value, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    showCreateModal.value = false
    incidentForm.value = { title: '', description: '', severity: 5, status: 'open' }
    await fetchIncidents()
  } catch (error) {
    console.error('Create failed:', error)
    alert('Create failed: ' + (error.response?.data?.error || error.message))
  } finally {
    creating.value = false
  }
}

const viewIncident = (incident) => {
  alert(`Incident #${incident.id}\n\n${incident.description}`)
}

const updateIncidentStatus = async (incident) => {
  const newStatus = prompt('Enter new status (open, investigating, resolved, closed):', incident.status)
  if (!newStatus) return

  try {
    await axios.put(`${API_URL}/api/incidents/${incident.id}`, {
      status: newStatus
    }, {
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })
    await fetchIncidents()
  } catch (error) {
    console.error('Update failed:', error)
    alert('Update failed')
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString()
}

const getSeverityClass = (severity) => {
  if (severity >= 8) return 'text-red-600 font-semibold'
  if (severity >= 5) return 'text-orange-600 font-semibold'
  return 'text-yellow-600 font-semibold'
}

const getStatusClass = (status) => {
  const classes = {
    open: 'bg-red-100 text-red-800',
    investigating: 'bg-yellow-100 text-yellow-800',
    resolved: 'bg-green-100 text-green-800',
    closed: 'bg-gray-100 text-gray-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}
</script>
