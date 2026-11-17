<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAccountsStore } from '@/stores/accounts'
import { useTransactionsStore } from '@/stores/transactions'
import SbCard from '@/components/common/SbCard.vue'
import SbAmount from '@/components/common/SbAmount.vue'
import SbButton from '@/components/common/SbButton.vue'
import {
  Wallet,
  Plus,
  ArrowUpRight,
  ArrowDownLeft,
  Building2,
  Smartphone,
  Coins,
  CreditCard,
  Trash2,
  X,
} from 'lucide-vue-next'
import type { AccountType, TransactionType } from '@/types'

const accountsStore = useAccountsStore()
const transactionsStore = useTransactionsStore()

// Modales
const showAccountModal = ref(false)
const showTxModal = ref(false)

// Formulario de cuenta
const accountForm = ref({
  name: '',
  type: 'bank' as AccountType,
  balance_initial: 0,
  institution: '',
})

// Formulario de transacción
const txForm = ref({
  account_id: '',
  type: 'expense' as TransactionType,
  amount: 0,
  description: '',
  transaction_date: new Date().toISOString().split('T')[0],
})

const submitting = ref(false)

onMounted(async () => {
  await Promise.all([
    accountsStore.fetchAccounts(),
    transactionsStore.fetchTransactions(),
  ])
  if (accountsStore.accounts.length > 0) {
    txForm.value.account_id = accountsStore.accounts[0].id
  }
})

function getAccountIcon(type: AccountType) {
  switch (type) {
    case 'bank': return Building2
    case 'digital_wallet': return Smartphone
    case 'cash': return Coins
    case 'savings': return Wallet
    default: return CreditCard
  }
}

async function handleCreateAccount() {
  if (!accountForm.value.name) return
  submitting.value = true
  try {
    await accountsStore.createAccount(accountForm.value)
    showAccountModal.value = false
    accountForm.value = {
      name: '',
      type: 'bank',
      balance_initial: 0,
      institution: '',
    }
  } catch (err) {
    alert('Error al crear cuenta')
  } finally {
    submitting.value = false
  }
}

async function handleCreateTx() {
  if (!txForm.value.description || txForm.value.amount <= 0 || !txForm.value.account_id) return
  submitting.value = true
  try {
    await transactionsStore.createTransaction(txForm.value)
    showTxModal.value = false
    txForm.value = {
      account_id: accountsStore.accounts[0]?.id || '',
      type: 'expense',
      amount: 0,
      description: '',
      transaction_date: new Date().toISOString().split('T')[0],
    }
  } catch (err) {
    alert('Error al registrar transacción')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="finance-view">
    <!-- Encabezado Financiero -->
    <div class="finance-header">
      <div class="header-info">
        <span class="header-label">Balance Total Disponible</span>
        <SbAmount :value="accountsStore.totalBalance" variant="display" :colored="false" />
      </div>
      <div class="header-actions">
        <SbButton variant="secondary" @click="showAccountModal = true">
          <Plus :size="16" />
          <span>Nueva Cuenta</span>
        </SbButton>
        <SbButton
          variant="primary"
          :disabled="accountsStore.accounts.length === 0"
          @click="showTxModal = true"
        >
          <Plus :size="16" />
          <span>Registrar Movimiento</span>
        </SbButton>
      </div>
    </div>

    <!-- Sección de Cuentas -->
    <section class="section-block">
      <div class="section-header">
        <h2 class="section-title">Mis Cuentas</h2>
        <span class="section-count">{{ accountsStore.accounts.length }} activas</span>
      </div>

      <div v-if="accountsStore.loading && accountsStore.accounts.length === 0" class="loading-state">
        Cargando cuentas...
      </div>

      <div v-else-if="accountsStore.accounts.length === 0" class="empty-box">
        <Wallet :size="32" class="empty-icon" />
        <p class="empty-title">No tienes cuentas registradas</p>
        <p class="empty-desc">Crea tu primera cuenta (Bancolombia, Nequi, Daviplata, Efectivo) para comenzar.</p>
        <SbButton variant="secondary" @click="showAccountModal = true">
          Crear mi primera cuenta
        </SbButton>
      </div>

      <div v-else class="accounts-grid">
        <SbCard
          v-for="account in accountsStore.accounts"
          :key="account.id"
          padding="md"
          class="account-card"
        >
          <div class="account-card__top">
            <div class="account-badge">
              <component :is="getAccountIcon(account.type)" :size="18" />
            </div>
            <div class="account-titles">
              <span class="account-name">{{ account.name }}</span>
              <span class="account-inst">{{ account.institution || account.type }}</span>
            </div>
            <button
              class="delete-btn"
              title="Eliminar cuenta"
              @click="accountsStore.deleteAccount(account.id)"
            >
              <Trash2 :size="14" />
            </button>
          </div>
          <div class="account-card__bottom">
            <span class="balance-label">Saldo actual</span>
            <SbAmount :value="account.balance_current" variant="title" :colored="false" />
          </div>
        </SbCard>
      </div>
    </section>

    <!-- Sección de Transacciones Recientes -->
    <section class="section-block">
      <div class="section-header">
        <h2 class="section-title">Últimas Transacciones</h2>
        <span class="section-count">{{ transactionsStore.transactions.length }} movimientos</span>
      </div>

      <div v-if="transactionsStore.loading && transactionsStore.transactions.length === 0" class="loading-state">
        Cargando movimientos...
      </div>

      <div v-else-if="transactionsStore.transactions.length === 0" class="empty-box">
        <p class="empty-desc">Aún no hay transacciones registradas.</p>
      </div>

      <div v-else class="tx-list">
        <div
          v-for="tx in transactionsStore.transactions"
          :key="tx.id"
          class="tx-row"
        >
          <div class="tx-icon" :class="`tx-icon--${tx.type}`">
            <ArrowDownLeft v-if="tx.type === 'income'" :size="16" />
            <ArrowUpRight v-else :size="16" />
          </div>
          <div class="tx-info">
            <span class="tx-desc">{{ tx.description }}</span>
            <span class="tx-date">{{ tx.transaction_date }}</span>
          </div>
          <div class="tx-amount">
            <SbAmount
              :value="tx.type === 'expense' ? -tx.amount : tx.amount"
              variant="body"
            />
          </div>
        </div>
      </div>
    </section>

    <!-- Modal: Crear Cuenta -->
    <div v-if="showAccountModal" class="modal-backdrop" @click.self="showAccountModal = false">
      <div class="modal-box">
        <div class="modal-header">
          <h3 class="modal-title">Nueva Cuenta</h3>
          <button class="close-btn" @click="showAccountModal = false">
            <X :size="18" />
          </button>
        </div>
        <form class="modal-form" @submit.prevent="handleCreateAccount">
          <div class="form-group">
            <label class="form-label">Nombre de la cuenta</label>
            <input
              v-model="accountForm.name"
              type="text"
              required
              class="form-input"
              placeholder="Ej. Nequi, Bancolombia, Efectivo"
            />
          </div>

          <div class="form-group">
            <label class="form-label">Tipo de cuenta</label>
            <select v-model="accountForm.type" class="form-input form-select">
              <option value="bank">Cuenta Bancaria</option>
              <option value="digital_wallet">Billetera Digital (Nequi/Daviplata)</option>
              <option value="cash">Efectivo</option>
              <option value="savings">Ahorros</option>
              <option value="custom">Personalizada</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Institución (Opcional)</label>
            <input
              v-model="accountForm.institution"
              type="text"
              class="form-input"
              placeholder="Ej. Bancolombia, Davivienda"
            />
          </div>

          <div class="form-group">
            <label class="form-label">Saldo Inicial (COP)</label>
            <input
              v-model.number="accountForm.balance_initial"
              type="number"
              step="1000"
              required
              class="form-input"
              placeholder="0"
            />
          </div>

          <div class="modal-actions">
            <SbButton variant="ghost" type="button" @click="showAccountModal = false">
              Cancelar
            </SbButton>
            <SbButton variant="primary" type="submit" :loading="submitting">
              Guardar Cuenta
            </SbButton>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal: Registrar Transacción -->
    <div v-if="showTxModal" class="modal-backdrop" @click.self="showTxModal = false">
      <div class="modal-box">
        <div class="modal-header">
          <h3 class="modal-title">Registrar Movimiento</h3>
          <button class="close-btn" @click="showTxModal = false">
            <X :size="18" />
          </button>
        </div>
        <form class="modal-form" @submit.prevent="handleCreateTx">
          <div class="type-selector">
            <button
              type="button"
              class="type-btn"
              :class="{ active: txForm.type === 'expense' }"
              @click="txForm.type = 'expense'"
            >
              Gasto
            </button>
            <button
              type="button"
              class="type-btn"
              :class="{ active: txForm.type === 'income' }"
              @click="txForm.type = 'income'"
            >
              Ingreso
            </button>
          </div>

          <div class="form-group">
            <label class="form-label">Cuenta</label>
            <select v-model="txForm.account_id" required class="form-input form-select">
              <option v-for="acc in accountsStore.accounts" :key="acc.id" :value="acc.id">
                {{ acc.name }} (Saldo: ${{ acc.balance_current.toLocaleString() }})
              </option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Descripción</label>
            <input
              v-model="txForm.description"
              type="text"
              required
              class="form-input"
              placeholder="Ej. Almuerzo, Uber, Sueldo"
            />
          </div>

          <div class="form-group">
            <label class="form-label">Monto (COP)</label>
            <input
              v-model.number="txForm.amount"
              type="number"
              min="1"
              required
              class="form-input"
              placeholder="Ej. 25000"
            />
          </div>

          <div class="form-group">
            <label class="form-label">Fecha</label>
            <input
              v-model="txForm.transaction_date"
              type="date"
              required
              class="form-input"
            />
          </div>

          <div class="modal-actions">
            <SbButton variant="ghost" type="button" @click="showTxModal = false">
              Cancelar
            </SbButton>
            <SbButton variant="primary" type="submit" :loading="submitting">
              Registrar
            </SbButton>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.finance-view {
  display: flex;
  flex-direction: column;
  gap: var(--space-8);
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
}

.finance-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.header-info {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.header-label {
  font-size: var(--text-sm);
  color: var(--color-on-surface-variant);
  font-weight: var(--weight-medium);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.header-actions {
  display: flex;
  gap: var(--space-3);
}

.section-block {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.section-title {
  font-size: var(--text-md);
  font-weight: var(--weight-semibold);
}

.section-count {
  font-size: var(--text-xs);
  color: var(--color-on-surface-variant);
}

.accounts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: var(--space-4);
}

.account-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.account-card__top {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.account-badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  background-color: var(--color-surface-container);
  color: var(--color-primary);
}

.account-titles {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
}

.account-name {
  font-weight: var(--weight-semibold);
  font-size: var(--text-base);
}

.account-inst {
  font-size: var(--text-xs);
  color: var(--color-on-surface-variant);
  text-transform: capitalize;
}

.delete-btn {
  color: var(--color-on-surface-variant);
  padding: 6px;
  border-radius: var(--radius-xs);
  opacity: 0.6;
}

.delete-btn:hover {
  opacity: 1;
  color: var(--color-error);
}

.account-card__bottom {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.balance-label {
  font-size: var(--text-xs);
  color: var(--color-on-surface-variant);
}

.empty-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: var(--space-3);
  padding: var(--space-8);
  border-radius: var(--radius-xl);
  border: 1px dashed var(--color-border);
  background-color: var(--color-surface-container-low);
}

.empty-icon {
  color: var(--color-on-surface-variant);
}

.empty-title {
  font-weight: var(--weight-semibold);
  font-size: var(--text-base);
}

.empty-desc {
  font-size: var(--text-sm);
  color: var(--color-on-surface-variant);
  max-width: 380px;
}

.tx-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.tx-row {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
}

.tx-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: var(--radius-sm);
}

.tx-icon--income {
  background-color: var(--color-success-container);
  color: var(--color-success);
}

.tx-icon--expense {
  background-color: var(--color-error-container);
  color: var(--color-error);
}

.tx-info {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
}

.tx-desc {
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
}

.tx-date {
  font-size: var(--text-xs);
  color: var(--color-on-surface-variant);
}

/* Modales */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background-color: var(--color-backdrop);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: var(--z-modal);
  padding: var(--space-4);
}

.modal-box {
  width: 100%;
  max-width: 440px;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-xl);
  padding: var(--space-6);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  box-shadow: var(--shadow-lg);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-title {
  font-size: var(--text-lg);
  font-weight: var(--weight-semibold);
}

.close-btn {
  color: var(--color-on-surface-variant);
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.form-label {
  font-size: var(--text-xs);
  font-weight: var(--weight-medium);
  color: var(--color-on-surface-variant);
}

.form-input {
  height: 40px;
  padding: 0 var(--space-4);
  border-radius: var(--radius-md);
  background-color: var(--color-surface-container);
  border: 1px solid var(--color-border);
  color: var(--color-on-surface);
  font-size: var(--text-sm);
}

.form-select {
  cursor: pointer;
}

.type-selector {
  display: flex;
  background-color: var(--color-surface-container);
  border-radius: var(--radius-md);
  padding: 3px;
  gap: 3px;
}

.type-btn {
  flex: 1;
  height: 34px;
  border-radius: var(--radius-sm);
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
  color: var(--color-on-surface-variant);
}

.type-btn.active {
  background-color: var(--color-surface);
  color: var(--color-primary);
  font-weight: var(--weight-semibold);
  box-shadow: var(--shadow-sm);
}

.modal-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: var(--space-2);
  margin-top: var(--space-2);
}
</style>
