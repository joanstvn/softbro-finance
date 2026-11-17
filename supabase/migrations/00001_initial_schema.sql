-- ==============================================================================
-- SOFTBRO FINANCE (sb Finance) — MASTER DATABASE SCHEMA
-- PostgreSQL + Supabase Auth + Row Level Security (RLS) + Automated Triggers
-- ==============================================================================

-- 1. EXTENSIONS & UTILITIES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function to handle updated_at timestamps automatically
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 2. USER PROFILES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  currency TEXT NOT NULL DEFAULT 'COP',
  timezone TEXT NOT NULL DEFAULT 'America/Bogota',
  date_format TEXT NOT NULL DEFAULT 'DD/MM/YYYY',
  theme TEXT NOT NULL DEFAULT 'dark' CHECK (theme IN ('light', 'dark')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" 
  ON public.profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
  ON public.profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Trigger to create profile automatically on auth.users registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Usuario sb Finance'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 3. FINANCIAL ACCOUNTS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('cash', 'bank', 'savings', 'digital_wallet', 'custom')),
  balance_initial NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
  balance_current NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
  currency TEXT NOT NULL DEFAULT 'COP',
  institution TEXT,
  color TEXT DEFAULT '#ffffff',
  icon TEXT DEFAULT 'wallet',
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own accounts" 
  ON public.accounts FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_accounts_user ON public.accounts(user_id);

CREATE TRIGGER update_accounts_updated_at 
  BEFORE UPDATE ON public.accounts 
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 4. CATEGORIES (Income & Expense)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  icon TEXT DEFAULT 'tag',
  color TEXT DEFAULT '#ffffff',
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own categories" 
  ON public.categories FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_categories_user ON public.categories(user_id, type);

-- ==============================================================================
-- 5. TRANSACTIONS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  transfer_id UUID, -- Links origin and destination of transfers
  type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer', 'adjustment')),
  amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
  currency TEXT NOT NULL DEFAULT 'COP',
  description TEXT NOT NULL,
  payment_method TEXT,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'pending', 'cancelled')),
  transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
  transaction_time TIME,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own transactions" 
  ON public.transactions FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON public.transactions(user_id, transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_account ON public.transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON public.transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_transfer ON public.transactions(transfer_id);

CREATE TRIGGER update_transactions_updated_at 
  BEFORE UPDATE ON public.transactions 
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger to maintain balance_current on accounts with atomic updates
CREATE OR REPLACE FUNCTION public.sync_account_balance()
RETURNS TRIGGER AS $$
BEGIN
  -- When inserting a confirmed transaction
  IF TG_OP = 'INSERT' AND NEW.status = 'confirmed' THEN
    UPDATE public.accounts SET balance_current = balance_current +
      CASE
        WHEN NEW.type = 'income' THEN NEW.amount
        WHEN NEW.type = 'expense' THEN -NEW.amount
        WHEN NEW.type = 'transfer' THEN -NEW.amount
        WHEN NEW.type = 'adjustment' THEN NEW.amount
        ELSE 0
      END
    WHERE id = NEW.account_id;
  END IF;

  -- When deleting a confirmed transaction
  IF TG_OP = 'DELETE' AND OLD.status = 'confirmed' THEN
    UPDATE public.accounts SET balance_current = balance_current -
      CASE
        WHEN OLD.type = 'income' THEN OLD.amount
        WHEN OLD.type = 'expense' THEN -OLD.amount
        WHEN OLD.type = 'transfer' THEN -OLD.amount
        WHEN OLD.type = 'adjustment' THEN OLD.amount
        ELSE 0
      END
    WHERE id = OLD.account_id;
  END IF;

  -- When updating a confirmed transaction
  IF TG_OP = 'UPDATE' THEN
    IF OLD.status = 'confirmed' THEN
      UPDATE public.accounts SET balance_current = balance_current -
        CASE
          WHEN OLD.type = 'income' THEN OLD.amount
          WHEN OLD.type = 'expense' THEN -OLD.amount
          WHEN OLD.type = 'transfer' THEN -OLD.amount
          WHEN OLD.type = 'adjustment' THEN OLD.amount
          ELSE 0
        END
      WHERE id = OLD.account_id;
    END IF;

    IF NEW.status = 'confirmed' THEN
      UPDATE public.accounts SET balance_current = balance_current +
        CASE
          WHEN NEW.type = 'income' THEN NEW.amount
          WHEN NEW.type = 'expense' THEN -NEW.amount
          WHEN NEW.type = 'transfer' THEN -NEW.amount
          WHEN NEW.type = 'adjustment' THEN NEW.amount
          ELSE 0
        END
      WHERE id = NEW.account_id;
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_account_balance ON public.transactions;
CREATE TRIGGER trg_sync_account_balance
  AFTER INSERT OR UPDATE OR DELETE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.sync_account_balance();

-- Atomic Transfer Stored Procedure
CREATE OR REPLACE FUNCTION public.execute_transfer(
  p_user_id UUID,
  p_from_account UUID,
  p_to_account UUID,
  p_amount NUMERIC,
  p_description TEXT,
  p_date DATE DEFAULT CURRENT_DATE
) RETURNS UUID AS $$
DECLARE
  v_transfer_id UUID := gen_random_uuid();
BEGIN
  IF p_amount <= 0 THEN
    RAISE EXCEPTION 'El monto debe ser mayor a cero';
  END IF;

  -- 1. Debit from source account
  INSERT INTO public.transactions (
    user_id, account_id, type, amount, description, transaction_date, transfer_id, status
  ) VALUES (
    p_user_id, p_from_account, 'transfer', p_amount, 
    'Transferencia a cuenta: ' || (SELECT name FROM public.accounts WHERE id = p_to_account),
    p_date, v_transfer_id, 'confirmed'
  );

  -- 2. Credit to destination account
  INSERT INTO public.transactions (
    user_id, account_id, type, amount, description, transaction_date, transfer_id, status
  ) VALUES (
    p_user_id, p_to_account, 'income', p_amount, 
    'Transferencia desde cuenta: ' || (SELECT name FROM public.accounts WHERE id = p_from_account),
    p_date, v_transfer_id, 'confirmed'
  );

  RETURN v_transfer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 6. BUDGETS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  period TEXT NOT NULL DEFAULT 'monthly' CHECK (period IN ('weekly', 'monthly', 'custom')),
  limit_amount NUMERIC(15, 2) NOT NULL CHECK (limit_amount > 0),
  spent_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
  currency TEXT NOT NULL DEFAULT 'COP',
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  alert_50 BOOLEAN NOT NULL DEFAULT true,
  alert_75 BOOLEAN NOT NULL DEFAULT true,
  alert_90 BOOLEAN NOT NULL DEFAULT true,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own budgets" 
  ON public.budgets FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_budgets_user ON public.budgets(user_id, is_active);

-- ==============================================================================
-- 7. SAVINGS GOALS & CONTRIBUTIONS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.savings_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id UUID REFERENCES public.accounts(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  target_amount NUMERIC(15, 2) NOT NULL CHECK (target_amount > 0),
  current_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
  currency TEXT NOT NULL DEFAULT 'COP',
  target_date DATE,
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.savings_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own savings goals" 
  ON public.savings_goals FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

-- Contributions
CREATE TABLE IF NOT EXISTS public.savings_contributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES public.savings_goals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
  contribution_date DATE NOT NULL DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.savings_contributions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own savings contributions" 
  ON public.savings_contributions FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

-- Trigger to update current_amount in savings_goals
CREATE OR REPLACE FUNCTION public.sync_savings_goal_progress()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.savings_goals 
    SET current_amount = current_amount + NEW.amount 
    WHERE id = NEW.goal_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.savings_goals 
    SET current_amount = current_amount - OLD.amount 
    WHERE id = OLD.goal_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_sync_savings_progress
  AFTER INSERT OR DELETE ON public.savings_contributions
  FOR EACH ROW EXECUTE FUNCTION public.sync_savings_goal_progress();

-- ==============================================================================
-- 8. DEBTS & DEBT PAYMENTS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.debts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('owe', 'owed')),
  counterparty TEXT NOT NULL,
  original_amount NUMERIC(15, 2) NOT NULL CHECK (original_amount > 0),
  remaining_amount NUMERIC(15, 2) NOT NULL CHECK (remaining_amount >= 0),
  interest_rate NUMERIC(5, 2),
  currency TEXT NOT NULL DEFAULT 'COP',
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date DATE,
  installments INTEGER,
  frequency TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paid', 'overdue', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own debts" 
  ON public.debts FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

-- Debt payments
CREATE TABLE IF NOT EXISTS public.debt_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  debt_id UUID NOT NULL REFERENCES public.debts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
  payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.debt_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own debt payments" 
  ON public.debt_payments FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.sync_debt_remaining()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.debts 
    SET remaining_amount = GREATEST(0, remaining_amount - NEW.amount),
        status = CASE WHEN remaining_amount - NEW.amount <= 0 THEN 'paid' ELSE status END
    WHERE id = NEW.debt_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_sync_debt_payment
  AFTER INSERT ON public.debt_payments
  FOR EACH ROW EXECUTE FUNCTION public.sync_debt_remaining();

-- ==============================================================================
-- 9. CARDS (Credit & Debit)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id UUID REFERENCES public.accounts(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
  institution TEXT NOT NULL,
  last_four VARCHAR(4) NOT NULL,
  credit_limit NUMERIC(15, 2),
  current_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
  closing_date SMALLINT CHECK (closing_date BETWEEN 1 AND 31),
  due_date SMALLINT CHECK (due_date BETWEEN 1 AND 31),
  color TEXT DEFAULT '#ffffff',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own cards" 
  ON public.cards FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 10. SUBSCRIPTIONS (Recurring Services)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id UUID REFERENCES public.accounts(id) ON DELETE SET NULL,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  provider TEXT NOT NULL,
  amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
  currency TEXT NOT NULL DEFAULT 'COP',
  frequency TEXT NOT NULL DEFAULT 'monthly' CHECK (frequency IN ('weekly', 'monthly', 'yearly', 'custom')),
  next_billing_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own subscriptions" 
  ON public.subscriptions FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 11. TASKS & ORGANIZATION
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  category TEXT,
  tags TEXT[] DEFAULT '{}',
  due_date DATE,
  reminder_at TIMESTAMPTZ,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own tasks" 
  ON public.tasks FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.subtasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own subtasks" 
  ON public.subtasks FOR ALL 
  USING (
    EXISTS (SELECT 1 FROM public.tasks WHERE tasks.id = subtasks.task_id AND tasks.user_id = auth.uid())
  );

-- ==============================================================================
-- 12. HABITS & HABIT LOGS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  frequency TEXT NOT NULL DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'specific_days')),
  target_days SMALLINT[] DEFAULT '{1,2,3,4,5,6,7}',
  target_value NUMERIC(10, 2) NOT NULL DEFAULT 1.00,
  unit TEXT,
  color TEXT DEFAULT '#ffffff',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own habits" 
  ON public.habits FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.habit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL DEFAULT CURRENT_DATE,
  value NUMERIC(10, 2) NOT NULL DEFAULT 1.00,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(habit_id, log_date)
);

ALTER TABLE public.habit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own habit logs" 
  ON public.habit_logs FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 13. GOALS & MILESTONES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL DEFAULT 'general',
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
  progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  target_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own goals" 
  ON public.goals FOR ALL 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.goal_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES public.goals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  target_date DATE,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.goal_milestones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own goal milestones" 
  ON public.goal_milestones FOR ALL 
  USING (
    EXISTS (SELECT 1 FROM public.goals WHERE goals.id = goal_milestones.goal_id AND goals.user_id = auth.uid())
  );

-- ==============================================================================
-- 14. DEFAULT CATEGORIES SEED FUNCTION
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.seed_default_categories(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Gastos
  INSERT INTO public.categories (user_id, name, type, icon, color, is_default, sort_order) VALUES
    (p_user_id, 'Alimentación', 'expense', 'utensils', '#ef4444', true, 1),
    (p_user_id, 'Transporte', 'expense', 'car', '#f97316', true, 2),
    (p_user_id, 'Vivienda y Servicios', 'expense', 'home', '#eab308', true, 3),
    (p_user_id, 'Salud', 'expense', 'activity', '#06b6d4', true, 4),
    (p_user_id, 'Educación', 'expense', 'book-open', '#3b82f6', true, 5),
    (p_user_id, 'Entretenimiento', 'expense', 'film', '#8b5cf6', true, 6),
    (p_user_id, 'Compras y Ropa', 'expense', 'shopping-bag', '#ec4899', true, 7),
    (p_user_id, 'Suscripciones', 'expense', 'credit-card', '#10b981', true, 8),
    (p_user_id, 'Otros Gastos', 'expense', 'more-horizontal', '#64748b', true, 9);

  -- Ingresos
  INSERT INTO public.categories (user_id, name, type, icon, color, is_default, sort_order) VALUES
    (p_user_id, 'Salario', 'income', 'briefcase', '#22c55e', true, 1),
    (p_user_id, 'Freelance', 'income', 'laptop', '#10b981', true, 2),
    (p_user_id, 'Inversiones', 'income', 'trending-up', '#06b6d4', true, 3),
    (p_user_id, 'Regalos', 'income', 'gift', '#ec4899', true, 4),
    (p_user_id, 'Otros Ingresos', 'income', 'plus-circle', '#64748b', true, 5);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
