<template>
  <div v-if="show" class="drawer-overlay" @click.self="close">
    <div class="drawer">
      <button class="close-btn" @click="close">&times;</button>
      <h3>{{ mode === 'login' ? 'Login' : 'Register' }}</h3>
      <form @submit.prevent="onSubmit">
        <input v-if="mode==='register'" v-model="name" type="text" placeholder="Your Name" required class="form-control mb-2" />
        <input v-model="email" type="email" placeholder="Email" required class="form-control mb-2" />
        <input v-model="password" type="password" placeholder="Password" required class="form-control mb-2" />
        <input v-if="mode==='register'" v-model="passwordConfirmation" type="password" placeholder="Confirm Password" required class="form-control mb-2" />
        <button class="btn btn-orange w-100" type="submit">
          {{ mode === 'login' ? 'Login' : 'Register' }}
        </button>
      </form>
      <div class="mt-3 text-center">
        <span v-if="mode==='login'">Don't have an account?
          <a href="#" @click.prevent="mode='register'">Register</a>
        </span>
        <span v-else>Already have an account?
          <a href="#" @click.prevent="mode='login'">Login</a>
        </span>
      </div>
      <div class="text-danger mt-2">{{ error }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { login, register } from '@/composables/auth'
import { useAuthState } from '@/composables/useAuthState'

const name = ref('')

const props = defineProps({
  show: Boolean
})
const emit = defineEmits(['close', 'authenticated'])

const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const error = ref('')
const mode = ref('login')

// import and use the auth state composable
const { login: setLoggedIn } = useAuthState()

function close() {
  emit('close')
  email.value = ''
  password.value = ''
  passwordConfirmation.value = ''
  error.value = ''
  mode.value = 'login'
}

async function onSubmit() {
  try {
    error.value = ''
    if (mode.value === 'login') {
      await login(email.value, password.value)
      setLoggedIn() // update global logged in state
      emit('authenticated')
      close()
    } else {
      if (password.value !== passwordConfirmation.value) {
        error.value = "Passwords do not match!"
        return
      }
      await register(email.value, password.value, passwordConfirmation.value, name.value)
      setLoggedIn() // update global logged in state
      emit('authenticated')
      close()
    }
  } catch (e) {
    error.value = e.response?.data?.errors?.[0] || "Login/Register failed."
  }
}
</script>

<style scoped>
.drawer-overlay {
  position: fixed;
  top: 0; right: 0; left: 0; bottom: 0;
  background: rgba(0,0,0,0.2);
  z-index: 2000;
  display: flex; justify-content: flex-end; align-items: stretch;
}
.drawer {
  width: 340px; max-width: 90vw; height: 100%; background: #fff;
  box-shadow: -2px 0 20px rgba(0,0,0,0.12);
  padding: 2.5rem 2rem 1.5rem 2rem;
  position: relative;
  animation: slidein 0.25s cubic-bezier(.29,1.01,1,-0.68);
  display: flex; flex-direction: column; justify-content: center;
}
@keyframes slidein {
  from { transform: translateX(100%); }
  to   { transform: translateX(0); }
}
.close-btn {
  position: absolute; right: 1.5rem; top: 1.5rem;
  background: none; border: none; font-size: 2rem;
  color: #888; cursor: pointer;
}
</style>
