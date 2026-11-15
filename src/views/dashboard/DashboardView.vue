<script setup lang="ts">
import { ref } from 'vue'
import SbCard from '@/components/common/SbCard.vue'
import SbAmount from '@/components/common/SbAmount.vue'
import SbButton from '@/components/common/SbButton.vue'
import {
  TrendingUp,
  Plus,
  ArrowUpRight,
  ArrowDownLeft,
  CheckCircle2,
} from 'lucide-vue-next'

// Mock de datos iniciales para el dashboard
const netWorth = ref(15850000)
const monthIncome = ref(4200000)
const monthExpense = ref(2150000)
const availableBudget = ref(2050000)

const pendingTasks = ref([
  { id: '1', title: 'Pagar tarjeta Bancolombia', due: 'Hoy', priority: 'high' },
  { id: '2', title: 'Revisar presupuesto mensual', due: 'Mañana', priority: 'medium' },
  { id: '3', title: 'Comprar víveres de la semana', due: '18 Nov', priority: 'low' },
])
</script>

<template>
  <div class="dashboard-view">
    <!-- Header del Dashboard -->
    <div class="dashboard-hero">
      <div class="hero-info">
        <span class="hero-label">Patrimonio Neto Total</span>
        <SbAmount :value="netWorth" variant="display" :colored="false" />
      </div>
      <div class="hero-actions">
        <SbButton variant="primary">
          <Plus :size="16" />
          <span>Nuevo Registro</span>
        </SbButton>
      </div>
    </div>

    <!-- KPI Grid Financiero -->
    <div class="kpi-grid">
      <SbCard padding="md">
        <div class="kpi-header">
          <span class="kpi-title">Ingresos del Mes</span>
          <div class="kpi-icon kpi-icon--income">
            <ArrowDownLeft :size="16" />
          </div>
        </div>
        <SbAmount :value="monthIncome" variant="title" />
        <span class="kpi-meta">+12% vs mes anterior</span>
      </SbCard>

      <SbCard padding="md">
        <div class="kpi-header">
          <span class="kpi-title">Gastos del Mes</span>
          <div class="kpi-icon kpi-icon--expense">
            <ArrowUpRight :size="16" />
          </div>
        </div>
        <SbAmount :value="-monthExpense" variant="title" />
        <span class="kpi-meta">51% del presupuesto</span>
      </SbCard>

      <SbCard padding="md">
        <div class="kpi-header">
          <span class="kpi-title">Disponible para Ahorro</span>
          <div class="kpi-icon">
            <TrendingUp :size="16" />
          </div>
        </div>
        <SbAmount :value="availableBudget" variant="title" :colored="false" />
        <span class="kpi-meta">49% de flujo libre</span>
      </SbCard>
    </div>

    <!-- Sección de Módulos Conectados -->
    <div class="modules-grid">
      <!-- Tareas Pendientes -->
      <SbCard padding="md" class="widget-card">
        <div class="widget-header">
          <h2 class="widget-title">Tareas Prioritarias</h2>
          <router-link to="/organization" class="widget-link">Ver todas</router-link>
        </div>
        <ul class="task-list">
          <li v-for="task in pendingTasks" :key="task.id" class="task-item">
            <CheckCircle2 :size="18" class="task-check" />
            <span class="task-name">{{ task.title }}</span>
            <span class="task-due">{{ task.due }}</span>
          </li>
        </ul>
      </SbCard>

      <!-- Hábitos de Hoy -->
      <SbCard padding="md" class="widget-card">
        <div class="widget-header">
          <h2 class="widget-title">Hábitos de Hoy</h2>
          <router-link to="/habits" class="widget-link">Gestionar</router-link>
        </div>
        <div class="habit-items">
          <div class="habit-badge completed">💧 Beber 2L de agua</div>
          <div class="habit-badge completed">🏃 30m Ejercicio</div>
          <div class="habit-badge">📚 15m Lectura</div>
        </div>
      </SbCard>
    </div>
  </div>
</template>

<style scoped>
.dashboard-view {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
}

.dashboard-hero {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  padding: var(--space-4) 0;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.hero-info {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.hero-label {
  font-size: var(--text-sm);
  color: var(--color-on-surface-variant);
  font-weight: var(--weight-medium);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: var(--space-4);
}

.kpi-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-3);
}

.kpi-title {
  font-size: var(--text-sm);
  color: var(--color-on-surface-variant);
  font-weight: var(--weight-medium);
}

.kpi-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: var(--radius-sm);
  background-color: var(--color-surface-container);
  color: var(--color-on-surface);
}

.kpi-icon--income {
  color: var(--color-success);
  background-color: var(--color-success-container);
}

.kpi-icon--expense {
  color: var(--color-error);
  background-color: var(--color-error-container);
}

.kpi-meta {
  font-size: var(--text-xs);
  color: var(--color-on-surface-subtle);
  margin-top: var(--space-2);
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: var(--space-4);
}

.widget-card {
  gap: var(--space-4);
}

.widget-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.widget-title {
  font-size: var(--text-md);
  font-weight: var(--weight-semibold);
}

.widget-link {
  font-size: var(--text-xs);
  color: var(--color-on-surface-variant);
  font-weight: var(--weight-medium);
}

.widget-link:hover {
  color: var(--color-primary);
}

.task-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.task-item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3);
  border-radius: var(--radius-md);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
}

.task-check {
  color: var(--color-outline);
  cursor: pointer;
}

.task-check:hover {
  color: var(--color-success);
}

.task-name {
  flex-grow: 1;
  font-size: var(--text-sm);
}

.task-due {
  font-size: var(--text-xs);
  color: var(--color-on-surface-variant);
}

.habit-items {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
}

.habit-badge {
  padding: 6px 12px;
  border-radius: var(--radius-pill);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  font-size: var(--text-sm);
}

.habit-badge.completed {
  border-color: var(--color-outline);
  background-color: var(--color-surface-container);
  color: var(--color-on-surface);
}
</style>
