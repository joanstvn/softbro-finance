<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import ThemeToggle from './ThemeToggle.vue'
import { Bell, Search } from 'lucide-vue-next'

const route = useRoute()

const pageTitle = computed(() => {
  const metaTitle = route.meta.title as string
  if (metaTitle) return metaTitle

  const titles: Record<string, string> = {
    '/dashboard': 'Inicio',
    '/finance': 'Finanzas',
    '/food': 'Alimentación',
    '/shopping': 'Compras',
    '/organization': 'Organización',
    '/habits': 'Hábitos',
    '/training': 'Entrenamiento',
    '/goals': 'Objetivos',
    '/subscriptions': 'Suscripciones',
    '/documents': 'Documentos',
    '/assistant': 'Asistente IA',
    '/settings': 'Configuración',
  }

  return titles[route.path] || 'softbro Finance'
})
</script>

<template>
  <header class="app-header">
    <div class="header-left">
      <h1 class="header-title">{{ pageTitle }}</h1>
    </div>

    <div class="header-right">
      <button class="header-action-btn" title="Buscar">
        <Search :size="18" />
      </button>

      <button class="header-action-btn" title="Notificaciones">
        <Bell :size="18" />
      </button>

      <div class="mobile-theme-toggle">
        <ThemeToggle />
      </div>
    </div>
  </header>
</template>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: var(--header-height);
  padding: 0 var(--space-6);
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
  z-index: var(--z-header);
}

.header-title {
  font-size: var(--text-lg);
  font-weight: var(--weight-semibold);
  letter-spacing: -0.01em;
}

.header-right {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.header-action-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  color: var(--color-on-surface-variant);
  transition: all var(--duration-fast);
}

.header-action-btn:hover {
  background-color: var(--color-surface-container);
  color: var(--color-primary);
}

.mobile-theme-toggle {
  display: none;
}

@media (max-width: 680px) {
  .app-header {
    padding: 0 var(--space-4);
  }

  .mobile-theme-toggle {
    display: block;
  }
}
</style>
