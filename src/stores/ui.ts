import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUiStore = defineStore('ui', () => {
  const sidebarOpen = ref(true)
  const mobileNavOpen = ref(false)
  const activeModal = ref<string | null>(null)

  function toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value
  }

  function openModal(id: string) {
    activeModal.value = id
  }

  function closeModal() {
    activeModal.value = null
  }

  return {
    sidebarOpen,
    mobileNavOpen,
    activeModal,
    toggleSidebar,
    openModal,
    closeModal,
  }
})
