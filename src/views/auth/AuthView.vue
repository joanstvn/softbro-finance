<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import SbButton from '@/components/common/SbButton.vue'
import { AlertCircle } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()

const isLogin = ref(true)
const email = ref('')
const password = ref('')
const fullName = ref('')
const errorMsg = ref('')
const loading = ref(false)

async function handleGoogleLogin() {
  errorMsg.value = ''
  try {
    await authStore.loginWithGoogle()
  } catch (err: any) {
    errorMsg.value = err.message || 'Error al conectar con Google'
  }
}

async function handleSubmit() {
  errorMsg.value = ''
  loading.value = true

  try {
    if (isLogin.value) {
      await authStore.login(email.value, password.value)
    } else {
      await authStore.register(email.value, password.value, fullName.value)
    }
    router.push('/dashboard')
  } catch (err: any) {
    errorMsg.value = err.message || 'Ocurrió un error en la autenticación'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth-container">
    <div class="auth-card">
      <div class="auth-header">
        <div class="logo-box">
          <span class="logo-badge">sb</span>
          <span class="logo-text">Finance</span>
        </div>
        <h2 class="auth-title">
          {{ isLogin ? 'Inicia sesión en tu cuenta' : 'Crear una nueva cuenta' }}
        </h2>
        <p class="auth-subtitle">
          {{ isLogin ? 'Gestiona tus finanzas personales y hábitos' : 'Empieza a controlar tus finanzas con precisión' }}
        </p>
      </div>

      <form class="auth-form" @submit.prevent="handleSubmit">
        <div v-if="errorMsg" class="auth-error">
          <AlertCircle :size="16" />
          <span>{{ errorMsg }}</span>
        </div>

        <div v-if="!isLogin" class="form-group">
          <label class="form-label" for="fullname">Nombre completo</label>
          <input
            id="fullname"
            v-model="fullName"
            type="text"
            required
            class="form-input"
            placeholder="Ej. Joan Stiven"
          />
        </div>

        <div class="form-group">
          <label class="form-label" for="email">Correo electrónico</label>
          <input
            id="email"
            v-model="email"
            type="email"
            required
            class="form-input"
            placeholder="tu@correo.com"
          />
        </div>

        <div class="form-group">
          <label class="form-label" for="password">Contraseña</label>
          <input
            id="password"
            v-model="password"
            type="password"
            required
            minlength="6"
            class="form-input"
            placeholder="••••••••"
          />
        </div>

        <SbButton
          type="submit"
          variant="primary"
          :full-width="true"
          :loading="loading"
        >
          {{ isLogin ? 'Entrar a softbro Finance' : 'Registrarme' }}
        </SbButton>

        <div class="divider">
          <span>o</span>
        </div>

        <button
          type="button"
          class="google-btn"
          @click="handleGoogleLogin"
        >
          <svg class="google-icon" viewBox="0 0 24 24" width="18" height="18">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
            />
          </svg>
          <span>Continuar con Google</span>
        </button>
      </form>

      <div class="auth-footer">
        <button
          type="button"
          class="switch-mode-btn"
          @click="isLogin = !isLogin; errorMsg = ''"
        >
          {{ isLogin ? '¿No tienes cuenta? Regístrate aquí' : '¿Ya tienes cuenta? Inicia sesión' }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  min-height: 100dvh;
  padding: var(--space-4);
  background-color: var(--color-background);
}

.auth-card {
  width: 100%;
  max-width: 420px;
  padding: var(--space-8);
  border-radius: var(--radius-2xl);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-md);
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.auth-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: var(--space-2);
}

.logo-box {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-2);
}

.logo-badge {
  background-color: var(--color-primary);
  color: var(--color-on-primary);
  font-weight: var(--weight-bold);
  font-size: var(--text-xs);
  padding: 3px 7px;
  border-radius: var(--radius-xs);
  letter-spacing: -0.05em;
}

.logo-text {
  font-weight: var(--weight-bold);
  font-size: var(--text-xl);
  letter-spacing: -0.02em;
}

.auth-title {
  font-size: var(--text-lg);
  font-weight: var(--weight-semibold);
  letter-spacing: -0.01em;
}

.auth-subtitle {
  font-size: var(--text-sm);
  color: var(--color-on-surface-variant);
}

.auth-form {
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
  width: 100%;
  height: 42px;
  padding: 0 var(--space-4);
  border-radius: var(--radius-md);
  background-color: var(--color-surface-container);
  border: 1px solid var(--color-border);
  color: var(--color-on-surface);
  font-size: var(--text-sm);
  transition: all var(--duration-fast);
}

.form-input:focus {
  border-color: var(--color-primary);
  outline: none;
}

.auth-error {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  background-color: var(--color-error-container);
  color: var(--color-on-error-container);
  font-size: var(--text-xs);
  font-weight: var(--weight-medium);
}

.divider {
  display: flex;
  align-items: center;
  text-align: center;
  color: var(--color-on-surface-subtle);
  font-size: var(--text-xs);
  margin: var(--space-2) 0;
}

.divider::before,
.divider::after {
  content: '';
  flex: 1;
  border-bottom: 1px solid var(--color-border);
}

.divider span {
  padding: 0 var(--space-3);
  text-transform: uppercase;
}

.google-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  width: 100%;
  height: 42px;
  border-radius: var(--radius-md);
  background-color: var(--color-surface-container);
  border: 1px solid var(--color-border);
  color: var(--color-on-surface);
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
  transition: all var(--duration-fast);
}

.google-btn:hover {
  background-color: var(--color-surface-container-high);
  border-color: var(--color-outline-variant);
}

.auth-footer {
  display: flex;
  justify-content: center;
}

.switch-mode-btn {
  font-size: var(--text-sm);
  color: var(--color-on-surface-variant);
  transition: color var(--duration-fast);
}

.switch-mode-btn:hover {
  color: var(--color-primary);
  text-decoration: underline;
}
</style>
