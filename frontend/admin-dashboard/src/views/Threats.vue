<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Threats</h1>
      <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
        New Threat Alert
      </button>
    </div>

    <div v-if="threatsStore.loading" class="text-center py-12">
      Loading threats...
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
              <span :class="getSeverityClass(threat.severity)">
                {{ threat.severity }}/10
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 text-xs rounded-full" :class="getStatusClass(threat.status)">
                {{ threat.status }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ threat.source_ip || '-' }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(threat.detected_at) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm">
              <router-link :to="`/threats/${threat.id}`" class="text-blue-600 hover:underline">
                View
              </router-link>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useThreatsStore } from '../stores/threats'
import { format } from 'date-fns'

const threatsStore = useThreatsStore()

onMounted(async () => {
  await threatsStore.fetchThreats()
})

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
