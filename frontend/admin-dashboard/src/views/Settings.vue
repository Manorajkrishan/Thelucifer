<template>
  <div>
    <h1 class="text-3xl font-bold mb-6">Settings</h1>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- System Settings -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold mb-4">⚙️ System Settings</h2>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">API URL</label>
            <input
              v-model="settings.apiUrl"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              placeholder="http://localhost:8000"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">ML Service URL</label>
            <input
              v-model="settings.mlServiceUrl"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              placeholder="http://localhost:5000"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Auto-refresh Interval (seconds)</label>
            <input
              v-model.number="settings.refreshInterval"
              type="number"
              min="10"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
            />
          </div>
          <button
            @click="saveSettings"
            class="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
          >
            Save Settings
          </button>
        </div>
      </div>

      <!-- User Management -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold mb-4">👥 User Management</h2>
        <div class="space-y-4">
          <div class="p-4 bg-gray-50 rounded-lg">
            <p class="text-sm text-gray-600">
              User management features coming soon. For now, manage users through the API or database.
            </p>
          </div>
          <button
            @click="refreshUserList"
            class="w-full bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700"
          >
            Refresh User List
          </button>
        </div>
      </div>

      <!-- ML Service Settings -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold mb-4">🤖 ML Service Settings</h2>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Learning Mode</label>
            <select v-model="settings.learningMode" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
              <option value="auto">Auto-learn from all sources</option>
              <option value="manual">Manual learning only</option>
              <option value="scheduled">Scheduled learning</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Model Training Frequency</label>
            <select v-model="settings.trainingFrequency" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
              <option value="daily">Daily</option>
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
              <option value="manual">Manual</option>
            </select>
          </div>
          <button
            @click="saveMLSettings"
            class="w-full bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700"
          >
            Save ML Settings
          </button>
        </div>
      </div>

      <!-- Datasets: Download your own -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold mb-4">📦 Datasets – Download &amp; store in project</h2>
        <p class="text-sm text-gray-600 mb-4">
          Download any dataset from a URL (CSV, JSON, ZIP) into <code class="bg-gray-100 px-1">backend/ml-service/datasets/custom/</code>. Use for learning.
        </p>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">URL</label>
            <input
              v-model="datasetUrl"
              type="url"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              placeholder="https://example.com/data.csv"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Folder name (optional)</label>
            <input
              v-model="datasetId"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              placeholder="my_dataset"
            />
          </div>
          <div v-if="datasetError" class="text-sm text-red-600">{{ datasetError }}</div>
          <div v-if="datasetSuccess" class="text-sm text-green-600">{{ datasetSuccess }}</div>
          <button
            :disabled="datasetLoading || !datasetUrl"
            @click="downloadDatasetToProject"
            class="w-full bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 disabled:opacity-50"
          >
            {{ datasetLoading ? 'Downloading…' : 'Download to project' }}
          </button>
        </div>
        <div class="mt-4">
          <button
            type="button"
            @click="listDownloadedDatasets"
            class="text-sm text-indigo-600 hover:underline"
          >
            List downloaded datasets
          </button>
          <ul v-if="downloadedDatasets.length" class="mt-2 text-sm text-gray-600 space-y-1">
            <li v-for="d in downloadedDatasets" :key="d.id">{{ d.name || d.id }} – {{ d.path }}</li>
          </ul>
        </div>
      </div>

      <!-- Notification Settings -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold mb-4">🔔 Notification Settings</h2>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <label class="text-sm font-medium text-gray-700">Email Notifications</label>
            <input
              v-model="settings.emailNotifications"
              type="checkbox"
              class="w-4 h-4 text-blue-600 rounded"
            />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm font-medium text-gray-700">Threat Alerts</label>
            <input
              v-model="settings.threatAlerts"
              type="checkbox"
              class="w-4 h-4 text-blue-600 rounded"
            />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm font-medium text-gray-700">Incident Notifications</label>
            <input
              v-model="settings.incidentNotifications"
              type="checkbox"
              class="w-4 h-4 text-blue-600 rounded"
            />
          </div>
          <button
            @click="saveNotificationSettings"
            class="w-full bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
          >
            Save Notification Settings
          </button>
        </div>
      </div>
    </div>

    <!-- System Info -->
    <div class="mt-6 bg-white rounded-lg shadow p-6">
      <h2 class="text-xl font-semibold mb-4">ℹ️ System Information</h2>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="p-4 bg-gray-50 rounded-lg">
          <div class="text-sm text-gray-600">API Status</div>
          <div class="text-lg font-semibold" :class="systemInfo.apiStatus === 'online' ? 'text-green-600' : 'text-red-600'">
            {{ systemInfo.apiStatus }}
          </div>
        </div>
        <div class="p-4 bg-gray-50 rounded-lg">
          <div class="text-sm text-gray-600">ML Service Status</div>
          <div class="text-lg font-semibold" :class="systemInfo.mlStatus === 'online' ? 'text-green-600' : 'text-red-600'">
            {{ systemInfo.mlStatus }}
          </div>
        </div>
        <div class="p-4 bg-gray-50 rounded-lg">
          <div class="text-sm text-gray-600">Database Status</div>
          <div class="text-lg font-semibold" :class="systemInfo.dbStatus === 'connected' ? 'text-green-600' : 'text-red-600'">
            {{ systemInfo.dbStatus }}
          </div>
        </div>
      </div>
      <button
        @click="checkSystemStatus"
        class="mt-4 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
      >
        Refresh Status
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'
const ML_SERVICE_URL = import.meta.env.VITE_ML_SERVICE_URL || 'http://localhost:5000'

const settings = ref({
  apiUrl: API_URL,
  mlServiceUrl: ML_SERVICE_URL,
  refreshInterval: 30,
  learningMode: 'auto',
  trainingFrequency: 'daily',
  emailNotifications: true,
  threatAlerts: true,
  incidentNotifications: true
})

const datasetUrl = ref('')
const datasetId = ref('')
const datasetLoading = ref(false)
const datasetError = ref('')
const datasetSuccess = ref('')
const downloadedDatasets = ref([])

const systemInfo = ref({
  apiStatus: 'checking...',
  mlStatus: 'checking...',
  dbStatus: 'checking...'
})

onMounted(() => {
  loadSettings()
  checkSystemStatus()
  const s = localStorage.getItem('adminSettings')
  if (s) {
    const parsed = JSON.parse(s)
    if (parsed.mlServiceUrl) settings.value.mlServiceUrl = parsed.mlServiceUrl
  }
})

const loadSettings = () => {
  const saved = localStorage.getItem('adminSettings')
  if (saved) {
    settings.value = { ...settings.value, ...JSON.parse(saved) }
  }
}

const saveSettings = () => {
  localStorage.setItem('adminSettings', JSON.stringify(settings.value))
  alert('Settings saved!')
}

const saveMLSettings = () => {
  localStorage.setItem('mlSettings', JSON.stringify({
    learningMode: settings.value.learningMode,
    trainingFrequency: settings.value.trainingFrequency
  }))
  alert('ML Settings saved!')
}

const saveNotificationSettings = () => {
  localStorage.setItem('notificationSettings', JSON.stringify({
    emailNotifications: settings.value.emailNotifications,
    threatAlerts: settings.value.threatAlerts,
    incidentNotifications: settings.value.incidentNotifications
  }))
  alert('Notification settings saved!')
}

const checkSystemStatus = async () => {
  systemInfo.value = {
    apiStatus: 'checking...',
    mlStatus: 'checking...',
    dbStatus: 'checking...'
  }

  // Check API
  try {
    // Try API health endpoint first, fallback to root
    try {
      await axios.get(`${API_URL}/api/health`, { timeout: 3000 })
      systemInfo.value.apiStatus = 'online'
    } catch {
      // Fallback to root endpoint
      await axios.get(`${API_URL}`, { timeout: 3000 })
      systemInfo.value.apiStatus = 'online'
    }
  } catch {
    systemInfo.value.apiStatus = 'offline'
  }

  // Check ML Service
  try {
    await axios.get(`${ML_SERVICE_URL}/health`)
    systemInfo.value.mlStatus = 'online'
  } catch {
    systemInfo.value.mlStatus = 'offline'
  }

  // Check Database (via API)
  try {
    await axios.get(`${API_URL}/api/threats/statistics`, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    systemInfo.value.dbStatus = 'connected'
  } catch {
    systemInfo.value.dbStatus = 'disconnected'
  }
}

const refreshUserList = () => {
  alert('User management API endpoint needed')
}

const getMlBase = () => settings.value?.mlServiceUrl || ML_SERVICE_URL

const downloadDatasetToProject = async () => {
  datasetError.value = ''
  datasetSuccess.value = ''
  datasetLoading.value = true
  try {
    const base = getMlBase()
    const body = { action: 'download-url', url: datasetUrl.value }
    if (datasetId.value) body.dataset_id = datasetId.value
    const r = await axios.post(`${base}/api/v1/datasets`, body, { timeout: 300000 })
    if (r.data?.success && r.data?.result) {
      datasetSuccess.value = `Saved to ${r.data.result.path}`
      datasetUrl.value = ''
      datasetId.value = ''
      await listDownloadedDatasets()
    } else {
      datasetError.value = r.data?.error || 'Download failed'
    }
  } catch (e) {
    datasetError.value = e.response?.data?.error || e.message || 'Request failed. Is ML service running?'
  } finally {
    datasetLoading.value = false
  }
}

const listDownloadedDatasets = async () => {
  try {
    const base = getMlBase()
    const r = await axios.get(`${base}/api/v1/datasets?type=downloaded`)
    downloadedDatasets.value = r.data?.datasets || []
  } catch {
    downloadedDatasets.value = []
  }
}
</script>
