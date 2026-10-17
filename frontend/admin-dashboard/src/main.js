import { createApp } from 'vue'
import { createPinia } from 'pinia'
import axios from 'axios'
import App from './App.vue'
import router from './router'
import { useAuthStore } from './stores/auth'
import './style.css'

// OCI private staging only: the existing Vercel project keeps its own isolated
// synthetic preview branch. All API requests here use same-origin /api via nginx.
const app = createApp(App)
const pinia = createPinia()
app.use(pinia)
app.use(router)

const authStore = useAuthStore()
axios.interceptors.request.use((config) => {
  if (!config.headers.Authorization && authStore.token) {
    config.headers.Authorization = `Bearer ${authStore.token}`
  }
  return config
})
axios.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 && authStore.isAuthenticated) {
      authStore.logout()
      router.replace('/login')
    }
    return Promise.reject(error)
  }
)
app.mount('#app')
