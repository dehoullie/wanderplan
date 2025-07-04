import axios from 'axios'

// Configure Axios for your API
const API = axios.create({
  baseURL: '/api/v1'
})

// Load JWT from localStorage if it exists
const token = localStorage.getItem('jwt')
if (token) {
  API.defaults.headers.common['Authorization'] = token
}

// LOGIN function
export async function login(email, password) {
  const { data, headers } = await API.post(
    '/login',
    { user: { email, password } },
    { headers: { "Content-Type": "application/json", "Accept": "application/json" } }
  )
  // Try to get token from headers, otherwise use data.token
  const token = headers.authorization || data.token
  if (token) {
    const bearerToken = token.startsWith('Bearer ') ? token : `Bearer ${token}`
    localStorage.setItem('jwt', bearerToken)
    API.defaults.headers.common['Authorization'] = bearerToken
  }
  return data
}

// REGISTER function
export async function register(email, password, password_confirmation, name) {
  const { data, headers } = await API.post('/register', {
    user: { email, password, password_confirmation, name }
  })
  const token = headers.authorization || data.token
  if (token) {
    const bearerToken = token.startsWith('Bearer ') ? token : `Bearer ${token}`
    localStorage.setItem('jwt', bearerToken)
    API.defaults.headers.common['Authorization'] = bearerToken
  }
  return data
}

// LOGOUT function
export async function logout() {
  localStorage.removeItem('jwt')
  delete API.defaults.headers.common['Authorization']
  return API.delete('/logout')
}

export default API
