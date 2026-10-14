import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

// Intentionally limited to features backed by the private Laravel API.
// No arbitrary document ingestion, ML browser calls, or counteroffensives.
const routes = [
  { path: '/login', name: 'Login', component: () => import('../views/Login.vue') },
  {
    path: '/',
    component: () => import('../layouts/DashboardLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'Dashboard', component: () => import('../views/Dashboard.vue') },
      { path: 'threats', name: 'Threats', component: () => import('../views/Threats.vue') },
      { path: 'threats/:id', name: 'ThreatDetail', component: () => import('../views/ThreatDetail.vue') },
      { path: 'incidents', name: 'Incidents', component: () => import('../views/Incidents.vue') }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]
const router = createRouter({ history: createWebHistory(), routes })
router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.isAuthenticated) return '/login'
  if (to.path === '/login' && auth.isAuthenticated) return '/'
})
export default router
