<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Threats</h1>
      <button
        class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        @click="showCreateModal = true"
      >
        New Threat Alert
      </button>
    </div>

    <div v-if="threatsStore.error" class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
      {{ threatsStore.error }}
      <span class="block mt-2 text-sm">Check API (http://localhost:8000), login, and CORS.</span>
      <button class="mt-2 text-sm underline" @click="retry">Retry</button>
    </div>

    <div v-if="threatsStore.loading" class="text-center py-12">
      Loading threats...
    </div>

    <div v-else-if="!threatsStore.threats.length && !threatsStore.error" class="text-center py-12 bg-white rounded-lg shadow">
      <p class="text-gray-500 mb-4">No threats yet.</p>
      <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700" @click="showCreateModal = true">
        Create first threat
      </button>
    </div>

    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Severity</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Source IP</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Detected</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="threat in threatsStore.threats" :key="threat.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ threat.id }}</td>
            <td class="px-6 py-4 whitespace-nowrap">
              <router-link :to="`/threats/${threat.id}`" class="text-blue-600 hover:underline">
                {{ threat.type }}
              </router-link>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span :class="getSeverityClass(threat.severity)">{{ threat.severity }}/10</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 text-xs rounded-full" :class="getStatusClass(threat.status)">
                {{ threat.status }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ threat.source_ip || '-' }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ formatDate(threat.detected_at) }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm">
              <router-link :to="`/threats/${threat.id}`" class="text-blue-600 hover:underline">View</router-link>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Create Threat Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" @click.self="showCreateModal = false">
      <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">New Threat Alert</h2>
        <form @submit.prevent="createThreat">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <input
                v-model="form.type"
                required
                class="w-full border border-gray-300 rounded px-3 py-2"
                placeholder="e.g. malware, phishing"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Severity (1–10)</label>
              <input
                v-model.number="form.severity"
                type="number"
                min="1"
                max="10"
                required
                class="w-full border border-gray-300 rounded px-3 py-2"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Source IP (optional)</label>
              <input
                v-model="form.source_ip"
                class="w-full border border-gray-300 rounded px-3 py-2"
                placeholder="e.g. 192.168.1.100"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
              <textarea
                v-model="form.description"
                required
                rows="3"
                class="w-full border border-gray-300 rounded px-3 py-2"
                placeholder="Brief description of the threat"
              />
            </div>
          </div>
          <div v-if="createError" class="mt-2 text-sm text-red-600">{{ createError }}</div>
          <div class="mt-6 flex gap-2 justify-end">
            <button type="button" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50" @click="showCreateModal = false">
              Cancel
            </button>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700" :disabled="creating">
              {{ creating ? 'Creating...' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useThreatsStore } from '../stores/threats'
import { format } from 'date-fns'

const threatsStore = useThreatsStore()
const showCreateModal = ref(false)
const creating = ref(false)
const createError = ref('')

const form = reactive({
  type: 'malware',
  severity: 7,
  source_ip: '',
  description: ''
})

onMounted(async () => {
  await threatsStore.fetchThreats()
})

async function retry() {
  threatsStore.error = null
  await threatsStore.fetchThreats()
}

async function createThreat() {
  creating.value = true
  createError.value = ''
  const res = await threatsStore.createThreat({
    type: form.type,
    severity: form.severity,
    source_ip: form.source_ip || undefined,
    description: form.description
  })
  creating.value = false
  if (res.success) {
    showCreateModal.value = false
    form.type = 'malware'
    form.severity = 7
    form.source_ip = ''
    form.description = ''
  } else {
    createError.value = res.error || 'Failed to create'
  }
}

function getSeverityClass(severity) {
  if (severity >= 8) return 'text-red-600 font-semibold'
  if (severity >= 5) return 'text-orange-600 font-semibold'
  return 'text-yellow-600 font-semibold'
}

function getStatusClass(status) {
  const classes = {
    detected: 'bg-red-100 text-red-800',
    analyzing: 'bg-yellow-100 text-yellow-800',
    mitigated: 'bg-blue-100 text-blue-800',
    resolved: 'bg-green-100 text-green-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

function formatDate(dateString) {
  if (!dateString) return '-'
  return format(new Date(dateString), 'MMM dd, yyyy HH:mm')
}
</script>
