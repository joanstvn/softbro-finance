<script setup lang="ts">
withDefaults(
  defineProps<{
    padding?: 'none' | 'sm' | 'md' | 'lg'
    bordered?: boolean
    interactive?: boolean
  }>(),
  {
    padding: 'md',
    bordered: true,
    interactive: false,
  }
)
</script>

<template>
  <div
    :class="[
      'sb-card',
      `sb-card--pad-${padding}`,
      {
        'sb-card--bordered': bordered,
        'sb-card--interactive': interactive,
      },
    ]"
  >
    <slot />
  </div>
</template>

<style scoped>
.sb-card {
  background-color: var(--color-surface-container-low);
  border-radius: var(--radius-xl);
  display: flex;
  flex-direction: column;
  position: relative;
  transition: all var(--duration-fast) var(--ease-standard);
}

.sb-card--bordered {
  border: 1px solid var(--color-border);
}

.sb-card--interactive:hover {
  background-color: var(--color-surface-container);
  border-color: var(--color-outline-variant);
  cursor: pointer;
}

.sb-card--pad-none {
  padding: 0;
}

.sb-card--pad-sm {
  padding: var(--space-4);
}

.sb-card--pad-md {
  padding: var(--space-6);
}

.sb-card--pad-lg {
  padding: var(--space-8);
}
</style>
