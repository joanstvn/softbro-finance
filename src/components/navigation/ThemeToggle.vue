<script setup lang="ts">
import { useThemeStore } from '@/stores/theme'
import { Sun, Moon } from 'lucide-vue-next'

const themeStore = useThemeStore()
</script>

<template>
  <button
    class="theme-toggle"
    :title="themeStore.theme === 'dark' ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro'"
    @click="themeStore.toggleTheme"
  >
    <Sun v-if="themeStore.theme === 'dark'" :size="18" />
    <Moon v-else :size="18" />
  </button>
</template>

<style scoped>
.theme-toggle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  color: var(--color-on-surface-variant);
  transition: all var(--duration-fast);
}

.theme-toggle:hover {
  background-color: var(--color-surface-container);
  color: var(--color-primary);
}
</style>
