<script setup lang="ts">
import AppSidebar from '@/components/navigation/AppSidebar.vue'
import AppHeader from '@/components/navigation/AppHeader.vue'
import AppMobileNav from '@/components/navigation/AppMobileNav.vue'
</script>

<template>
  <div class="app-layout">
    <div class="app-container">
      <AppSidebar />
      <div class="app-main-content">
        <AppHeader />
        <main class="app-view">
          <router-view />
        </main>
      </div>
      <AppMobileNav />
    </div>
  </div>
</template>

<style scoped>
.app-layout {
  display: flex;
  width: 100vw;
  height: 100vh;
  height: 100dvh;
  overflow: hidden;
  background-color: var(--color-background);
}

.app-main-content {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  height: 100%;
  overflow: hidden;
}
</style>
