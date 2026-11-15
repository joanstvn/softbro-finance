<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
    size?: 'sm' | 'md' | 'lg'
    disabled?: boolean
    loading?: boolean
    fullWidth?: boolean
    type?: 'button' | 'submit' | 'reset'
  }>(),
  {
    variant: 'secondary',
    size: 'md',
    disabled: false,
    loading: false,
    fullWidth: false,
    type: 'button',
  }
)

defineEmits<{
  (e: 'click', event: MouseEvent): void
}>()

const buttonClasses = computed(() => [
  'sb-btn',
  `sb-btn--${props.variant}`,
  `sb-btn--${props.size}`,
  {
    'sb-btn--loading': props.loading,
    'sb-btn--full': props.fullWidth,
  },
])
</script>

<template>
  <button
    :type="type"
    :class="buttonClasses"
    :disabled="disabled || loading"
    @click="$emit('click', $event)"
  >
    <span v-if="loading" class="sb-btn__spinner"></span>
    <span class="sb-btn__content">
      <slot />
    </span>
  </button>
</template>

<style scoped>
.sb-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  border-radius: var(--radius-md);
  font-family: var(--font-family);
  font-weight: var(--weight-medium);
  transition: all var(--duration-fast) var(--ease-standard);
  border: 1px solid transparent;
  cursor: pointer;
  white-space: nowrap;
}

.sb-btn:active {
  transform: scale(0.98);
}

.sb-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
}

/* Tamaños */
.sb-btn--sm {
  height: 32px;
  padding: 0 var(--space-4);
  font-size: var(--text-sm);
  border-radius: var(--radius-sm);
}

.sb-btn--md {
  height: 40px;
  padding: 0 var(--space-6);
  font-size: var(--text-base);
}

.sb-btn--lg {
  height: 48px;
  padding: 0 var(--space-8);
  font-size: var(--text-md);
  border-radius: var(--radius-lg);
}

.sb-btn--full {
  width: 100%;
}

/* Variantes monocromáticas */
.sb-btn--primary {
  background-color: var(--color-primary);
  color: var(--color-on-primary);
}

.sb-btn--primary:hover:not(:disabled) {
  opacity: 0.9;
}

.sb-btn--secondary {
  background-color: var(--color-surface-container);
  color: var(--color-on-surface);
  border-color: var(--color-border);
}

.sb-btn--secondary:hover:not(:disabled) {
  background-color: var(--color-surface-container-high);
}

.sb-btn--ghost {
  background-color: transparent;
  color: var(--color-on-surface-variant);
}

.sb-btn--ghost:hover:not(:disabled) {
  background-color: var(--color-surface-container);
  color: var(--color-on-surface);
}

.sb-btn--danger {
  background-color: var(--color-error-container);
  color: var(--color-on-error-container);
}

.sb-btn--danger:hover:not(:disabled) {
  opacity: 0.9;
}

.sb-btn__content {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
}

.sb-btn__spinner {
  width: 14px;
  height: 14px;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: var(--radius-full);
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
