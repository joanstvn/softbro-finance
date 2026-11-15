import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import AppLayout from '@/layouts/AppLayout.vue'
import DashboardView from '@/views/dashboard/DashboardView.vue'
import GenericView from '@/views/common/GenericView.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: AppLayout,
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
        component: GenericView,
        props: { title: 'Finanzas', description: 'Administra tus cuentas, presupuestos y transacciones.' },
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
        path: 'training',
        name: 'training',
        component: GenericView,
        props: { title: 'Entrenamiento', description: 'Rutinas de ejercicio y seguimiento de progreso.' },
        meta: { title: 'Entrenamiento' },
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
        path: 'documents',
        name: 'documents',
        component: GenericView,
        props: { title: 'Documentos', description: 'Almacenamiento seguro de facturas y archivos.' },
        meta: { title: 'Documentos' },
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
