<script setup lang="ts">
import SbCard from '@/components/common/SbCard.vue'

defineProps<{
  title: string
  description?: string
}>()
</script>

<template>
  <div class="generic-view">
    <div class="view-header">
      <h2 class="view-title">{{ title }}</h2>
      <p v-if="description" class="view-desc">{{ description }}</p>
    </div>

    <SbCard padding="lg" class="empty-placeholder">
      <div class="placeholder-content">
        <span class="placeholder-tag">Módulo en Desarrollo</span>
        <h3>{{ title }}</h3>
        <p>Este módulo será implementado progresivamente según el plan maestro.</p>
      </div>
    </SbCard>
  </div>
</template>

<style scoped>
.generic-view {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
}

.view-header {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.view-title {
  font-size: var(--text-2xl);
  font-weight: var(--weight-bold);
  letter-spacing: -0.02em;
}

.view-desc {
  color: var(--color-on-surface-variant);
  font-size: var(--text-base);
}

.empty-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 280px;
  text-align: center;
}

.placeholder-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
  max-width: 400px;
}

.placeholder-tag {
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 4px 10px;
  border-radius: var(--radius-pill);
  background-color: var(--color-surface-container-high);
  color: var(--color-on-surface-variant);
}
</style>
