import { createApp } from 'vue'
import { createPinia } from 'pinia'
import axios from 'axios'
import App from './App.vue'
import router from './router'
import { useAuthStore } from './stores/auth'
import './style.css'

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
  (r) => r,
  (err) => {
    if (err.response?.status === 401) {
      authStore.logout()
      router.push('/login')
    }
    return Promise.reject(err)
  }
)

app.mount('#app')
