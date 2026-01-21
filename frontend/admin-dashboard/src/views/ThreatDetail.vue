<template>
  <div>
    <div v-if="threatsStore.loading" class="text-center py-12">
      Loading threat details...
    </div>
    
    <div v-else-if="threatsStore.currentThreat">
      <div class="mb-6">
        <router-link to="/threats" class="text-blue-600 hover:underline">
          ← Back to Threats
        </router-link>
      </div>
      
      <div class="bg-white rounded-lg shadow p-6">
        <h1 class="text-3xl font-bold mb-4">{{ threatsStore.currentThreat.type }}</h1>
        
        <div class="grid grid-cols-2 gap-4 mb-6">
          <div>
            <label class="text-gray-500 text-sm">Severity</label>
            <div class="text-2xl font-bold" :class="getSeverityClass(threatsStore.currentThreat.severity)">
              {{ threatsStore.currentThreat.severity }}/10
            </div>
          </div>
          
          <div>
            <label class="text-gray-500 text-sm">Status</label>
            <div>
              <span class="px-3 py-1 rounded-full" :class="getStatusClass(threatsStore.currentThreat.status)">
                {{ threatsStore.currentThreat.status }}
              </span>
            </div>
          </div>
          
          <div>
            <label class="text-gray-500 text-sm">Source IP</label>
            <div class="font-mono">{{ threatsStore.currentThreat.source_ip || '-' }}</div>
          </div>
          
          <div>
            <label class="text-gray-500 text-sm">Detected At</label>
            <div>{{ formatDate(threatsStore.currentThreat.detected_at) }}</div>
          </div>
        </div>
        
        <div class="mb-6">
          <label class="text-gray-500 text-sm block mb-2">Description</label>
          <p class="text-gray-900">{{ threatsStore.currentThreat.description }}</p>
        </div>
        
        <div v-if="threatsStore.currentThreat.metadata" class="mb-6">
          <label class="text-gray-500 text-sm block mb-2">Metadata</label>
          <pre class="bg-gray-100 p-4 rounded text-sm overflow-auto">{{ JSON.stringify(threatsStore.currentThreat.metadata, null, 2) }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useThreatsStore } from '../stores/threats'
import { format } from 'date-fns'

const route = useRoute()
const threatsStore = useThreatsStore()

onMounted(async () => {
  await threatsStore.fetchThreat(route.params.id)
})

function getSeverityClass(severity) {
  if (severity >= 8) return 'text-red-600'
  if (severity >= 5) return 'text-orange-600'
  return 'text-yellow-600'
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
  return format(new Date(dateString), 'MMM dd, yyyy HH:mm:ss')
}
</script>
