<script setup lang="ts">
import { useRoute } from 'vue-router'
import ThemeToggle from './ThemeToggle.vue'
import {
  LayoutDashboard,
  Wallet,
  UtensilsCrossed,
  ShoppingCart,
  CheckSquare,
  Target,
  Dumbbell,
  Flag,
  CreditCard,
  FileText,
  Bot,
  Settings,
} from 'lucide-vue-next'

const route = useRoute()

const navItems = [
  { name: 'Inicio', path: '/dashboard', icon: LayoutDashboard },
  { name: 'Finanzas', path: '/finance', icon: Wallet },
  { name: 'Alimentación', path: '/food', icon: UtensilsCrossed },
  { name: 'Compras', path: '/shopping', icon: ShoppingCart },
  { name: 'Organización', path: '/organization', icon: CheckSquare },
  { name: 'Hábitos', path: '/habits', icon: Target },
  { name: 'Entrenamiento', path: '/training', icon: Dumbbell },
  { name: 'Objetivos', path: '/goals', icon: Flag },
  { name: 'Suscripciones', path: '/subscriptions', icon: CreditCard },
  { name: 'Documentos', path: '/documents', icon: FileText },
  { name: 'Asistente IA', path: '/assistant', icon: Bot },
]

function isActive(path: string) {
  if (path === '/dashboard') return route.path === '/dashboard'
  return route.path.startsWith(path)
}
</script>

<template>
  <aside class="app-sidebar">
    <div class="sidebar-header">
      <div class="logo-box">
        <span class="logo-badge">sb</span>
        <span class="logo-text">Finance</span>
      </div>
    </div>

    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li v-for="item in navItems" :key="item.path">
          <router-link
            :to="item.path"
            class="nav-button"
            :data-active="isActive(item.path)"
          >
            <component :is="item.icon" :size="20" class="nav-icon" />
            <span class="nav-label">{{ item.name }}</span>
          </router-link>
        </li>
      </ul>
    </nav>

    <div class="sidebar-footer">
      <router-link
        to="/settings"
        class="nav-button"
        :data-active="isActive('/settings')"
      >
        <Settings :size="20" class="nav-icon" />
        <span class="nav-label">Configuración</span>
      </router-link>
      <div class="footer-actions">
        <ThemeToggle />
      </div>
    </div>
  </aside>
</template>

<style scoped>
.app-sidebar {
  display: flex;
  flex-direction: column;
  width: var(--sidebar-width);
  min-width: var(--sidebar-width);
  height: 100%;
  background-color: var(--color-surface);
  border-right: 1px solid var(--color-border);
  box-sizing: border-box;
  z-index: var(--z-sidebar);
}

.sidebar-header {
  display: flex;
  align-items: center;
  height: var(--header-height);
  padding: 0 var(--space-6);
  border-bottom: 1px solid var(--color-border);
}

.logo-box {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  user-select: none;
}

.logo-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-primary);
  color: var(--color-on-primary);
  font-weight: var(--weight-bold);
  font-size: var(--text-xs);
  padding: 2px 6px;
  border-radius: var(--radius-xs);
  letter-spacing: -0.05em;
}

.logo-text {
  font-weight: var(--weight-bold);
  font-size: var(--text-lg);
  letter-spacing: -0.02em;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  padding: var(--space-4) var(--space-3);
  overflow-y: auto;
  gap: var(--space-1);
}

.nav-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.nav-button {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  height: 40px;
  padding: 0 var(--space-4);
  border-radius: var(--radius-md);
  color: var(--color-on-surface-variant);
  font-size: var(--text-base);
  font-weight: var(--weight-medium);
  transition: all var(--duration-fast) var(--ease-standard);
  user-select: none;
}

.nav-button:hover {
  background-color: var(--color-surface-container);
  color: var(--color-primary);
}

.nav-button[data-active="true"] {
  background-color: var(--color-surface-container-high);
  color: var(--color-primary);
  font-weight: var(--weight-semibold);
}

.nav-icon {
  flex-shrink: 0;
  color: inherit;
}

.nav-label {
  flex-grow: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sidebar-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-3) var(--space-4);
  border-top: 1px solid var(--color-border);
  gap: var(--space-2);
}

.sidebar-footer .nav-button {
  flex-grow: 1;
}

.footer-actions {
  display: flex;
  align-items: center;
}

@media (max-width: 680px) {
  .app-sidebar {
    display: none;
  }
}
</style>
