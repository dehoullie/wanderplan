// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// only your compiled SCSS — no direct bootstrap CSS import
import '@/assets/styles/main.scss'
import 'bootstrap'               // only Bootstrap JS (for modals, dropdowns, etc)
import VCalendar from 'v-calendar'
import 'v-calendar/style.css'

const app = createApp(App)
app.use(router)
app.use(VCalendar, {
  componentPrefix: 'vc'  // <vc-date-picker> component
})
app.mount('#app')
