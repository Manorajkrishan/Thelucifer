<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Sidebar -->
    <aside class="fixed inset-y-0 left-0 w-64 bg-gray-900 text-white">
      <div class="flex items-center justify-center h-16 bg-gray-800">
        <h1 class="text-xl font-bold">SentinelAI X</h1>
      </div>
      
      <nav class="mt-8">
        <router-link
          v-for="item in navigation"
          :key="item.name"
          :to="item.to"
          class="flex items-center px-6 py-3 text-gray-300 hover:bg-gray-800 hover:text-white"
          :class="{ 'bg-gray-800 text-white': $route.path === item.to }"
        >
          <component :is="item.icon" class="w-5 h-5 mr-3" />
          {{ item.name }}
        </router-link>
      </nav>
    </aside>

    <!-- Main Content -->
    <div class="ml-64">
      <!-- Top Navigation -->
      <header class="bg-white shadow-sm">
        <div class="flex items-center justify-between px-6 py-4">
          <h2 class="text-2xl font-semibold text-gray-800">{{ pageTitle }}</h2>
          
          <div class="flex items-center space-x-4">
            <button
              @click="authStore.logout()"
              class="px-4 py-2 text-sm text-gray-700 hover:text-gray-900"
            >
              Logout
            </button>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="p-6">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const route = useRoute()
const authStore = useAuthStore()

const navigation = [
  { name: 'Dashboard', to: '/', icon: 'HomeIcon' },
  { name: 'Threats', to: '/threats', icon: 'ShieldExclamationIcon' },
  { name: 'Documents', to: '/documents', icon: 'DocumentIcon' },
  { name: 'Incidents', to: '/incidents', icon: 'ExclamationTriangleIcon' },
  { name: 'Simulations', to: '/simulations', icon: 'CpuChipIcon' },
  { name: 'Settings', to: '/settings', icon: 'CogIcon' }
]

const pageTitle = computed(() => {
  const routeName = route.name
  const item = navigation.find(n => n.to === route.path || route.path.startsWith(n.to))
  return item ? item.name : 'Dashboard'
})
</script>
