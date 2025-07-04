import { ref } from 'vue'
import axios from 'axios'

export function useCurrentUser() {
  const user = ref(null)
  const loading = ref(false)

  async function fetchCurrentUser() {
    loading.value = true
    try {
      const res = await axios.get('http://localhost:3000/api/v1/me', {
        withCredentials: true
      })
      user.value = res.data
    } catch {
      user.value = null
    } finally {
      loading.value = false
    }
  }

  return { user, loading, fetchCurrentUser }
}
