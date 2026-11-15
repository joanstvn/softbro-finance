<script setup lang="ts">
import { computed } from 'vue'
import { formatCurrency } from '@/utils/formatters'
import type { CurrencyCode } from '@/types'

const props = withDefaults(
  defineProps<{
    value: number
    currency?: CurrencyCode
    variant?: 'display' | 'title' | 'body' | 'chip'
    colored?: boolean
  }>(),
  {
    currency: 'COP',
    variant: 'body',
    colored: true,
  }
)

const isPositive = computed(() => props.value > 0)
const isNegative = computed(() => props.value < 0)
const isZero = computed(() => props.value === 0)

const formattedValue = computed(() => formatCurrency(props.value, props.currency))
</script>

<template>
  <span
    :class="[
      'sb-amount',
      `sb-amount--${variant}`,
      {
        'sb-amount--positive': colored && isPositive,
        'sb-amount--negative': colored && isNegative,
        'sb-amount--zero': colored && isZero,
      },
    ]"
  >
    {{ formattedValue }}
  </span>
</template>

<style scoped>
.sb-amount {
  font-family: var(--font-mono);
  font-weight: var(--weight-medium);
  letter-spacing: -0.02em;
  white-space: nowrap;
}

.sb-amount--display {
  font-size: var(--text-display);
  font-weight: var(--weight-bold);
  line-height: 1.1;
}

.sb-amount--title {
  font-size: var(--text-2xl);
  font-weight: var(--weight-semibold);
}

.sb-amount--body {
  font-size: var(--text-base);
}

.sb-amount--chip {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: var(--text-sm);
  background-color: var(--color-surface-container);
}

/* Colores semánticos */
.sb-amount--positive {
  color: var(--color-success);
}

.sb-amount--negative {
  color: var(--color-error);
}

.sb-amount--zero {
  color: var(--color-on-surface-variant);
}

.sb-amount--chip.sb-amount--positive {
  background-color: var(--color-success-container);
  color: var(--color-on-success-container);
}

.sb-amount--chip.sb-amount--negative {
  background-color: var(--color-error-container);
  color: var(--color-on-error-container);
}

@media (max-width: 680px) {
  .sb-amount--display {
    font-size: var(--text-3xl);
  }
}
</style>
