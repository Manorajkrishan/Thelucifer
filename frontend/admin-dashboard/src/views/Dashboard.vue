<template>
  <div>
    <h1 class="text-3xl font-bold mb-6">Dashboard</h1>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-gray-500 text-sm">Total Threats</div>
        <div class="text-3xl font-bold text-gray-900">{{ statistics?.total || 0 }}</div>
      </div>
      
      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-gray-500 text-sm">Active Threats</div>
        <div class="text-3xl font-bold text-red-600">{{ statistics?.by_status?.detected || 0 }}</div>
      </div>
      
      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-gray-500 text-sm">Last 24h</div>
        <div class="text-3xl font-bold text-orange-600">{{ statistics?.recent_24h || 0 }}</div>
      </div>
      
      <div class="bg-white rounded-lg shadow p-6">
        <div class="text-gray-500 text-sm">Resolved</div>
        <div class="text-3xl font-bold text-green-600">{{ statistics?.by_status?.resolved || 0 }}</div>
      </div>
    </div>

    <!-- Recent Threats -->
    <div class="bg-white rounded-lg shadow">
      <div class="p-6 border-b">
        <h2 class="text-xl font-semibold">Recent Threats</h2>
      </div>
      
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Severity</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Detected</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="threat in recentThreats" :key="threat.id" class="hover:bg-gray-50">
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
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(threat.detected_at) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue'
import { useThreatsStore } from '../stores/threats'
import { format } from 'date-fns'

const threatsStore = useThreatsStore()

const statistics = computed(() => threatsStore.statistics)
const recentThreats = computed(() => threatsStore.threats.slice(0, 10))

onMounted(async () => {
  await threatsStore.fetchStatistics()
  await threatsStore.fetchThreats({ per_page: 10 })
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
