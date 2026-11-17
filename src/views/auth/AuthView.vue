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
