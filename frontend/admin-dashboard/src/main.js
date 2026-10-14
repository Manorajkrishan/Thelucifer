import { createApp } from 'vue'
import PreviewDashboard from './PreviewDashboard.vue'
import './style.css'

// Deliberately disconnected from the Laravel API, ML service, and socket server.
// Access control MUST be provided by Vercel Authentication at the edge.
createApp(PreviewDashboard).mount('#app')
