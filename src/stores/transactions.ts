import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/services/supabase'
import { useAuthStore } from './auth'
import { useAccountsStore } from './accounts'
import type { Transaction, TransactionType } from '@/types'

export const useTransactionsStore = defineStore('transactions', () => {
  const transactions = ref<Transaction[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchTransactions() {
    loading.value = true
    error.value = null
    try {
      const authStore = useAuthStore()
      if (!authStore.user) {
        transactions.value = []
        return
      }

      const { data, error: err } = await supabase
        .from('transactions')
        .select('*')
        .eq('user_id', authStore.user.id)
        .order('transaction_date', { ascending: false })
        .order('created_at', { ascending: false })

      if (err) throw err
      transactions.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Error fetching transactions:', err)
    } finally {
      loading.value = false
    }
  }

  async function createTransaction(txData: {
    account_id: string
    category_id?: string | null
    type: TransactionType
    amount: number
    description: string
    payment_method?: string
    notes?: string
    transaction_date?: string
  }) {
    loading.value = true
    try {
      const authStore = useAuthStore()
      const accountsStore = useAccountsStore()
      if (!authStore.user) throw new Error('Usuario no autenticado')

      const newTx = {
        user_id: authStore.user.id,
        account_id: txData.account_id,
        category_id: txData.category_id || null,
        type: txData.type,
        amount: txData.amount,
        description: txData.description,
        payment_method: txData.payment_method || null,
        notes: txData.notes || null,
        currency: 'COP',
        status: 'confirmed',
        transaction_date: txData.transaction_date || new Date().toISOString().split('T')[0],
      }

      const { data, error: err } = await supabase
        .from('transactions')
        .insert(newTx)
        .select()
        .single()

      if (err) throw err
      transactions.value.unshift(data)

      // Actualizar saldos de las cuentas en memoria
      await accountsStore.fetchAccounts()
      return data
    } catch (err: any) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteTransaction(id: string) {
    try {
      const accountsStore = useAccountsStore()
      const { error: err } = await supabase
        .from('transactions')
        .delete()
        .eq('id', id)

      if (err) throw err
      transactions.value = transactions.value.filter(t => t.id !== id)
      await accountsStore.fetchAccounts()
    } catch (err: any) {
      error.value = err.message
      throw err
    }
  }

  return {
    transactions,
    loading,
    error,
    fetchTransactions,
    createTransaction,
    deleteTransaction,
  }
})
