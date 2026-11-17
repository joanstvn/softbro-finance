import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import AppLayout from '@/layouts/AppLayout.vue'
import DashboardView from '@/views/dashboard/DashboardView.vue'
import FinanceView from '@/views/finance/FinanceView.vue'
import AuthView from '@/views/auth/AuthView.vue'
import GenericView from '@/views/common/GenericView.vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/services/supabase'

const routes: RouteRecordRaw[] = [
  {
    path: '/auth',
    name: 'auth',
    component: AuthView,
    meta: { guestOnly: true },
  },
  {
    path: '/',
    component: AppLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/dashboard',
      },
      {
        path: 'dashboard',
        name: 'dashboard',
        component: DashboardView,
        meta: { title: 'Inicio' },
      },
      {
        path: 'finance',
        name: 'finance',
        component: FinanceView,
        meta: { title: 'Finanzas' },
      },
      {
        path: 'food',
        name: 'food',
        component: GenericView,
        props: { title: 'Alimentación', description: 'Planificador de comidas y recetas semanales.' },
        meta: { title: 'Alimentación' },
      },
      {
        path: 'shopping',
        name: 'shopping',
        component: GenericView,
        props: { title: 'Compras', description: 'Listas automáticas de compras e inventario del hogar.' },
        meta: { title: 'Compras' },
      },
      {
        path: 'organization',
        name: 'organization',
        component: GenericView,
        props: { title: 'Organización', description: 'Gestión de tareas, rutinas y calendario.' },
        meta: { title: 'Organización' },
      },
      {
        path: 'habits',
        name: 'habits',
        component: GenericView,
        props: { title: 'Hábitos', description: 'Seguimiento de hábitos diarios y rachas.' },
        meta: { title: 'Hábitos' },
      },
      {
        path: 'goals',
        name: 'goals',
        component: GenericView,
        props: { title: 'Objetivos', description: 'Metas a corto, mediano y largo plazo con hitos.' },
        meta: { title: 'Objetivos' },
      },
      {
        path: 'subscriptions',
        name: 'subscriptions',
        component: GenericView,
        props: { title: 'Suscripciones', description: 'Control de pagos recurrentes y fechas de cobro.' },
        meta: { title: 'Suscripciones' },
      },
      {
        path: 'assistant',
        name: 'assistant',
        component: GenericView,
        props: { title: 'Asistente IA', description: 'Consultas inteligentes y operaciones asistidas.' },
        meta: { title: 'Asistente IA' },
      },
      {
        path: 'settings',
        name: 'settings',
        component: GenericView,
        props: { title: 'Configuración', description: 'Preferencias de perfil, moneda y seguridad.' },
        meta: { title: 'Configuración' },
      },
    ],
  },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to, _from, next) => {
  const authStore = useAuthStore()

  // Si viene del callback de OAuth con el hash en la URL (#access_token=...)
  if (window.location.hash.includes('access_token')) {
    const { data } = await supabase.auth.getSession()
    if (data.session) {
      authStore.session = data.session
      authStore.user = data.session.user
      await authStore.fetchProfile(data.session.user.id)
      return next({ name: 'dashboard' })
    }
  }

  if (authStore.loading) {
    await authStore.initializeAuth()
  }

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return next({ name: 'auth' })
  }

  if (to.meta.guestOnly && authStore.isAuthenticated) {
    return next({ name: 'dashboard' })
  }

  next()
})
