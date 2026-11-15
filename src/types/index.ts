export type CurrencyCode = 'COP' | 'USD' | 'EUR'

export interface Profile {
  id: string
  user_id: string
  full_name: string | null
  avatar_url: string | null
  currency: CurrencyCode
  timezone: string
  date_format: string
  theme: 'light' | 'dark'
  created_at: string
  updated_at: string
}

export type AccountType = 'cash' | 'bank' | 'savings' | 'digital_wallet' | 'custom'

export interface Account {
  id: string
  user_id: string
  name: string
  type: AccountType
  balance_initial: number
  balance_current: number
  currency: CurrencyCode
  institution: string | null
  color: string
  icon: string
  is_active: boolean
  sort_order: number
  created_at: string
  updated_at: string
}

export type TransactionType = 'income' | 'expense' | 'transfer' | 'adjustment'
export type TransactionStatus = 'confirmed' | 'pending' | 'cancelled'

export interface Transaction {
  id: string
  user_id: string
  account_id: string
  category_id: string | null
  transfer_id: string | null
  type: TransactionType
  amount: number
  currency: CurrencyCode
  description: string
  payment_method: string | null
  notes: string | null
  status: TransactionStatus
  receipt_url: string | null
  transaction_date: string
  transaction_time: string | null
  created_at: string
  updated_at: string
}

export interface TransactionCategory {
  id: string
  user_id: string
  parent_id: string | null
  name: string
  type: 'income' | 'expense'
  icon: string
  color: string
  sort_order: number
  is_default: boolean
  created_at: string
}

export interface Budget {
  id: string
  user_id: string
  category_id: string | null
  name: string
  period: 'weekly' | 'monthly' | 'custom'
  limit_amount: number
  spent_amount: number
  currency: CurrencyCode
  start_date: string
  end_date: string
  alert_50: boolean
  alert_75: boolean
  alert_90: boolean
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface SavingsGoal {
  id: string
  user_id: string
  account_id: string | null
  name: string
  description: string | null
  target_amount: number
  current_amount: number
  currency: CurrencyCode
  target_date: string | null
  priority: 'low' | 'medium' | 'high'
  status: 'active' | 'paused' | 'completed' | 'cancelled'
  created_at: string
  updated_at: string
}

export interface Debt {
  id: string
  user_id: string
  type: 'owe' | 'owed'
  counterparty: string
  original_amount: number
  remaining_amount: number
  interest_rate: number | null
  currency: CurrencyCode
  start_date: string
  due_date: string | null
  installments: number | null
  frequency: string | null
  status: 'active' | 'paid' | 'overdue' | 'cancelled'
  notes: string | null
  created_at: string
  updated_at: string
}

export interface Card {
  id: string
  user_id: string
  name: string
  type: 'credit' | 'debit'
  institution: string
  last_four: string
  credit_limit: number | null
  current_balance: number
  closing_date: number | null
  due_date: number | null
  account_id: string | null
  color: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Subscription {
  id: string
  user_id: string
  account_id: string | null
  category_id: string | null
  name: string
  provider: string
  amount: number
  currency: CurrencyCode
  frequency: 'monthly' | 'yearly' | 'weekly' | 'custom'
  next_billing_date: string
  status: 'active' | 'paused' | 'cancelled'
  notes: string | null
  created_at: string
  updated_at: string
}

export interface Task {
  id: string
  user_id: string
  title: string
  description: string | null
  priority: 'low' | 'medium' | 'high' | 'urgent'
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
  category: string | null
  tags: string[]
  due_date: string | null
  reminder_at: string | null
  sort_order: number
  created_at: string
  updated_at: string
}

export interface Habit {
  id: string
  user_id: string
  name: string
  description: string | null
  category: string | null
  frequency: 'daily' | 'weekly' | 'specific_days'
  target_days: number[]
  target_value: number
  unit: string | null
  color: string
  is_active: boolean
  created_at: string
  updated_at: string
}
