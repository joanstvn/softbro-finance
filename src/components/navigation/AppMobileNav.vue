<script setup lang="ts">
import { useRoute } from 'vue-router'
import {
  LayoutDashboard,
  Wallet,
  CheckSquare,
  ShoppingCart,
  Bot,
} from 'lucide-vue-next'

const route = useRoute()

const mobileItems = [
  { name: 'Inicio', path: '/dashboard', icon: LayoutDashboard },
  { name: 'Finanzas', path: '/finance', icon: Wallet },
  { name: 'Tareas', path: '/organization', icon: CheckSquare },
  { name: 'Compras', path: '/shopping', icon: ShoppingCart },
  { name: 'Asistente', path: '/assistant', icon: Bot },
]

function isActive(path: string) {
  if (path === '/dashboard') return route.path === '/dashboard'
  return route.path.startsWith(path)
}
</script>

<template>
  <nav class="app-mobile-nav">
    <router-link
      v-for="item in mobileItems"
      :key="item.path"
      :to="item.path"
      class="mobile-nav-btn"
      :data-active="isActive(item.path)"
    >
      <component :is="item.icon" :size="20" />
      <span class="mobile-nav-label">{{ item.name }}</span>
    </router-link>
  </nav>
</template>

<style scoped>
.app-mobile-nav {
  display: none;
}

@media (max-width: 680px) {
  .app-mobile-nav {
    display: flex;
    align-items: center;
    justify-content: space-around;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: var(--mobile-nav-height);
    background-color: var(--color-surface);
    border-top: 1px solid var(--color-border);
    padding-bottom: env(safe-area-inset-bottom);
    z-index: var(--z-header);
  }

  .mobile-nav-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    flex: 1;
    height: 100%;
    color: var(--color-on-surface-variant);
    font-size: var(--text-xs);
    font-weight: var(--weight-medium);
  }

  .mobile-nav-btn[data-active="true"] {
    color: var(--color-primary);
    font-weight: var(--weight-semibold);
  }
}
</style>
