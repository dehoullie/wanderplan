import { createRouter, createWebHistory } from 'vue-router'
import LayoutRoute from '@/layouts/LayoutRoute.vue'

import Home from '@/pages/Home.vue'
import PlanningPage from '@/pages/PlanningPage.vue'
import ItineraryShow from '@/pages/ItineraryShow.vue'
// import other pages...

const routes = [
  {
    path: '/',
    component: LayoutRoute,
    props: { component: Home }
  },
   {
    path: '/planning',
    component: LayoutRoute,
    props: { component: PlanningPage }
  },
  {
    path: '/itinerary/:id',
    component: LayoutRoute,
    props: { component: ItineraryShow }
  }

  // Add other routes here the same way
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
