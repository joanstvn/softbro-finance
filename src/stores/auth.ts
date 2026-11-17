import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase, isSupabaseConfigured } from '@/services/supabase'
import type { User, Session } from '@supabase/supabase-js'
import type { Profile } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const session = ref<Session | null>(null)
  const profile = ref<Profile | null>(null)
  const loading = ref(true)

  const isAuthenticated = computed(() => !!user.value)

  async function initializeAuth() {
    loading.value = true
    try {
      if (!isSupabaseConfigured) {
        loading.value = false
        return
      }

      const { data } = await supabase.auth.getSession()
      session.value = data.session
      user.value = data.session?.user || null

      if (user.value) {
        await fetchProfile(user.value.id)
      }

      supabase.auth.onAuthStateChange(async (_event, newSession) => {
        session.value = newSession
        user.value = newSession?.user || null
        if (user.value) {
          await fetchProfile(user.value.id)
        } else {
          profile.value = null
        }
      })
    } catch (err) {
      console.error('Error initializing auth:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchProfile(userId: string) {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single()

      if (!error && data) {
        profile.value = data as Profile
      }
    } catch (err) {
      console.error('Error fetching profile:', err)
    }
  }

  async function login(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
    session.value = data.session
    user.value = data.user
    if (data.user) {
      await fetchProfile(data.user.id)
    }
    return data
  }

  async function register(email: string, password: string, fullName: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    })
    if (error) throw error
    session.value = data.session
    user.value = data.user
    return data
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    session.value = null
    profile.value = null
  }

  return {
    user,
    session,
    profile,
    loading,
    isAuthenticated,
    initializeAuth,
    login,
    register,
    logout,
  }
})
