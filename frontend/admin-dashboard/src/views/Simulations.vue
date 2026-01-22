<template>
  <div>
    <h1 class="text-3xl font-bold mb-6">Simulations</h1>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Defensive Simulation -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold mb-4">🛡️ Defensive Simulation</h2>
        <form @submit.prevent="runDefensiveSimulation" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Attack Type</label>
            <select v-model="defensiveForm.attackType" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
              <option value="sql_injection">SQL Injection</option>
              <option value="xss">Cross-Site Scripting (XSS)</option>
              <option value="ddos">DDoS Attack</option>
              <option value="malware">Malware</option>
              <option value="phishing">Phishing</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Attack Data (JSON)</label>
            <textarea
              v-model="defensiveForm.attackData"
              rows="4"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg font-mono text-sm"
              placeholder='{"source_ip": "192.168.1.100", "payload": "SELECT * FROM users"}'
            ></textarea>
          </div>
          <button
            type="submit"
            :disabled="runningSimulation"
            class="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {{ runningSimulation ? 'Running...' : 'Run Defensive Simulation' }}
          </button>
        </form>

        <div v-if="defensiveResult" class="mt-4 p-4 bg-gray-50 rounded-lg">
          <h3 class="font-semibold mb-2">Results:</h3>
          <pre class="text-xs overflow-auto">{{ JSON.stringify(defensiveResult, null, 2) }}</pre>
        </div>
      </div>

      <!-- Counter-Offensive Simulation -->
      <div class="bg-white rounded-lg shadow p-6 border-2 border-red-200">
        <h2 class="text-xl font-semibold mb-4">⚔️ Counter-Offensive Simulation</h2>
        <p class="text-sm text-red-600 mb-4">⚠️ This is a SIMULATED counter-offensive system</p>
        
        <form @submit.prevent="runCounterOffensive" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Select Threat</label>
            <select v-model="counterForm.threatId" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
              <option value="">Select a threat...</option>
              <option v-for="threat in threats" :key="threat.id" :value="threat.id">
                {{ threat.type }} (Severity: {{ threat.severity }}/10)
              </option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Or Enter Attack Data (JSON)</label>
            <textarea
              v-model="counterForm.attackData"
              rows="4"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg font-mono text-sm"
              placeholder='{"source_ip": "192.168.1.100", "attack_type": "SQL Injection", "payload": "..."}'
            ></textarea>
          </div>
          <button
            type="submit"
            :disabled="runningCounter"
            class="w-full bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 disabled:opacity-50"
          >
            {{ runningCounter ? 'Executing...' : 'Execute Counter-Offensive' }}
          </button>
        </form>

        <div v-if="counterResult" class="mt-4 space-y-3">
          <div class="p-4 bg-gray-50 rounded-lg">
            <h3 class="font-semibold mb-2">Attacker Profile:</h3>
            <pre class="text-xs overflow-auto">{{ JSON.stringify(counterResult.attacker_profile, null, 2) }}</pre>
          </div>
          <div class="p-4 bg-gray-50 rounded-lg">
            <h3 class="font-semibold mb-2">Validation:</h3>
            <pre class="text-xs overflow-auto">{{ JSON.stringify(counterResult.validation, null, 2) }}</pre>
          </div>
          <div class="p-4 bg-gray-50 rounded-lg">
            <h3 class="font-semibold mb-2">Counter-Offensive Result:</h3>
            <pre class="text-xs overflow-auto">{{ JSON.stringify(counterResult.counter_offensive, null, 2) }}</pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useThreatsStore } from '../stores/threats'
import axios from 'axios'

const ML_SERVICE_URL = import.meta.env.VITE_ML_SERVICE_URL || 'http://localhost:5000'
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const threatsStore = useThreatsStore()
const threats = ref([])
const runningSimulation = ref(false)
const runningCounter = ref(false)
const defensiveResult = ref(null)
const counterResult = ref(null)

const defensiveForm = ref({
  attackType: 'sql_injection',
  attackData: '{}'
})

const counterForm = ref({
  threatId: '',
  attackData: '{}'
})

onMounted(async () => {
  await threatsStore.fetchThreats()
  threats.value = threatsStore.threats
})

const runDefensiveSimulation = async () => {
  runningSimulation.value = true
  defensiveResult.value = null

  try {
    let attackData = {}
    try {
      attackData = JSON.parse(defensiveForm.value.attackData)
    } catch {
      attackData = { attack_type: defensiveForm.value.attackType }
    }

    const response = await axios.post(`${ML_SERVICE_URL}/api/v1/simulations/run`, {
      simulation_type: 'defensive',
      attack_data: attackData
    })

    defensiveResult.value = response.data
  } catch (error) {
    console.error('Simulation failed:', error)
    alert('Simulation failed: ' + (error.response?.data?.error || error.message))
  } finally {
    runningSimulation.value = false
  }
}

const runCounterOffensive = async () => {
  runningCounter.value = true
  counterResult.value = null

  try {
    let attackData = {}
    
    if (counterForm.value.threatId) {
      // Get threat data
      const threat = threats.value.find(t => t.id === parseInt(counterForm.value.threatId))
      if (threat) {
        attackData = {
          source_ip: threat.source_ip,
          attack_type: threat.type,
          severity: threat.severity,
          description: threat.description
        }
      }
    } else {
      try {
        attackData = JSON.parse(counterForm.value.attackData)
      } catch {
        attackData = { source_ip: '192.168.1.100', attack_type: 'Unknown' }
      }
    }

    const response = await axios.post(`${ML_SERVICE_URL}/api/v1/counter-offensive/execute`, {
      attack_data: attackData
    })

    counterResult.value = response.data
  } catch (error) {
    console.error('Counter-offensive failed:', error)
    alert('Counter-offensive failed: ' + (error.response?.data?.error || error.message))
  } finally {
    runningCounter.value = false
  }
}
</script>
