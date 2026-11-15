import { defineStore } from 'pinia'
import { ref } from 'vue'

export type Theme = 'light' | 'dark'

export const useThemeStore = defineStore('theme', () => {
  const currentTheme = ref<Theme>(
    (localStorage.getItem('sb-theme') as Theme) || 'dark'
  )

  function applyTheme(theme: Theme) {
    currentTheme.value = theme
    document.documentElement.setAttribute('data-theme', theme)
    localStorage.setItem('sb-theme', theme)

    const metaThemeColor = document.querySelector('meta[name="theme-color"]')
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', theme === 'dark' ? '#000000' : '#ffffff')
    }
  }

  function toggleTheme() {
    applyTheme(currentTheme.value === 'dark' ? 'light' : 'dark')
  }

  // Inicializar tema en carga
  applyTheme(currentTheme.value)

  return {
    theme: currentTheme,
    applyTheme,
    toggleTheme,
  }
})
