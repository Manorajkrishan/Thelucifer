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

    <!-- Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
      <div class="bg-white rounded-lg shadow p-6 lg:col-span-2">
        <h2 class="text-lg font-semibold mb-4">Threats over time (last 7 days)</h2>
        <div class="h-64">
          <Line v-if="chartDataTime.labels.length" :data="chartDataTime" :options="chartOptionsLine" />
          <p v-else class="text-gray-500 text-sm">No data yet.</p>
        </div>
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold mb-4">By severity</h2>
        <div class="h-64 flex items-center justify-center">
          <Doughnut v-if="chartDataSeverity.labels.length" :data="chartDataSeverity" :options="chartOptionsDoughnut" />
          <p v-else class="text-gray-500 text-sm">No data yet.</p>
        </div>
      </div>
      <div class="bg-white rounded-lg shadow p-6 lg:col-span-3">
        <h2 class="text-lg font-semibold mb-4">By type</h2>
        <div class="h-64">
          <Bar v-if="chartDataType.labels.length" :data="chartDataType" :options="chartOptionsBar" />
          <p v-else class="text-gray-500 text-sm">No data yet.</p>
        </div>
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
import { Line, Bar, Doughnut } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js'
import { useThreatsStore } from '../stores/threats'
import { format } from 'date-fns'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
)

const threatsStore = useThreatsStore()

const statistics = computed(() => threatsStore.statistics)
const recentThreats = computed(() => threatsStore.threats.slice(0, 10))

const chartDataTime = computed(() => {
  const byDate = statistics.value?.by_date || []
  return {
    labels: byDate.map((d) => d.date),
    datasets: [
      {
        label: 'Threats',
        data: byDate.map((d) => d.count),
        borderColor: 'rgb(59, 130, 246)',
        backgroundColor: 'rgba(59, 130, 246, 0.1)',
        fill: true,
        tension: 0.2,
      },
    ],
  }
})

const chartDataSeverity = computed(() => {
  const by = statistics.value?.by_severity || {}
  const labels = Object.keys(by).sort((a, b) => Number(a) - Number(b))
  const colors = [
    'rgb(34, 197, 94)',
    'rgb(234, 179, 8)',
    'rgb(249, 115, 22)',
    'rgb(239, 68, 68)',
  ]
  return {
    labels: labels.map((s) => `Severity ${s}`),
    datasets: [
      {
        data: labels.map((k) => by[k]),
        backgroundColor: labels.map((_, i) => colors[i % colors.length]),
        borderWidth: 1,
      },
    ],
  }
})

const chartDataType = computed(() => {
  const by = statistics.value?.by_type || {}
  const labels = Object.keys(by)
  return {
    labels,
    datasets: [
      {
        label: 'Threats',
        data: labels.map((k) => by[k]),
        backgroundColor: 'rgba(59, 130, 246, 0.6)',
        borderColor: 'rgb(59, 130, 246)',
        borderWidth: 1,
      },
    ],
  }
})

const chartOptionsLine = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, ticks: { stepSize: 1 } },
  },
}

const chartOptionsDoughnut = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { position: 'bottom' } },
}

const chartOptionsBar = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, ticks: { stepSize: 1 } },
  },
}

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
