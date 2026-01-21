import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('../layouts/DashboardLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue')
      },
      {
        path: 'threats',
        name: 'Threats',
        component: () => import('../views/Threats.vue')
      },
      {
        path: 'threats/:id',
        name: 'ThreatDetail',
        component: () => import('../views/ThreatDetail.vue')
      },
      {
        path: 'documents',
        name: 'Documents',
        component: () => import('../views/Documents.vue')
      },
      {
        path: 'incidents',
        name: 'Incidents',
        component: () => import('../views/Incidents.vue')
      },
      {
        path: 'simulations',
        name: 'Simulations',
        component: () => import('../views/Simulations.vue')
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('../views/Settings.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    next('/')
  } else {
    next()
  }
})

export default router
