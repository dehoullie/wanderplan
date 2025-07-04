import { ref } from 'vue'

// Is the user logged in? (check JWT on load)
const isLoggedIn = ref(!!localStorage.getItem('jwt'))

export function useAuthState() {
  // Listen to login/logout (optional, can use events too)
  function login() {
    isLoggedIn.value = true
    // console.log('User logged in, isLoggedIn:', isLoggedIn.value)
  }
  function logout() {
    localStorage.removeItem('jwt')
    isLoggedIn.value = false
    // console.log('User logged out, isLoggedIn:', isLoggedIn.value)
  }
  return { isLoggedIn, login, logout }
}
