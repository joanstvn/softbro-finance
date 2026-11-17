import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/services/supabase'
import { useAuthStore } from './auth'
import type { Account, AccountType } from '@/types'

export const useAccountsStore = defineStore('accounts', () => {
  const accounts = ref<Account[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const totalBalance = computed(() => {
    return accounts.value.reduce((sum, acc) => sum + Number(acc.balance_current), 0)
  })

  async function fetchAccounts() {
    loading.value = true
    error.value = null
    try {
      const authStore = useAuthStore()
      if (!authStore.user) {
        accounts.value = []
        return
      }

      const { data, error: err } = await supabase
        .from('accounts')
        .select('*')
        .eq('user_id', authStore.user.id)
        .order('sort_order', { ascending: true })
        .order('created_at', { ascending: true })

      if (err) throw err
      accounts.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Error fetching accounts:', err)
    } finally {
      loading.value = false
    }
  }

  async function createAccount(accountData: {
    name: string
    type: AccountType
    balance_initial: number
    institution?: string
    color?: string
    icon?: string
  }) {
    loading.value = true
    try {
      const authStore = useAuthStore()
      if (!authStore.user) throw new Error('Usuario no autenticado')

      const newAccount = {
        user_id: authStore.user.id,
        name: accountData.name,
        type: accountData.type,
        balance_initial: accountData.balance_initial,
        balance_current: accountData.balance_initial,
        institution: accountData.institution || null,
        color: accountData.color || '#ffffff',
        icon: accountData.icon || 'wallet',
        currency: 'COP',
        is_active: true,
        sort_order: accounts.value.length,
      }

      const { data, error: err } = await supabase
        .from('accounts')
        .insert(newAccount)
        .select()
        .single()

      if (err) throw err
      accounts.value.push(data)
      return data
    } catch (err: any) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteAccount(id: string) {
    try {
      const { error: err } = await supabase
        .from('accounts')
        .delete()
        .eq('id', id)

      if (err) throw err
      accounts.value = accounts.value.filter(a => a.id !== id)
    } catch (err: any) {
      error.value = err.message
      throw err
    }
  }

  return {
    accounts,
    loading,
    error,
    totalBalance,
    fetchAccounts,
    createAccount,
    deleteAccount,
  }
})
