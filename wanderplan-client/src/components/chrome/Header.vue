<template>
  <header class="container-fluid py-3">
    <div class="container d-flex justify-content-between align-items-center">
      <div class="d-flex align-items-center">
          <a href="/">
            <img src="@/assets/images/wanderplan-logo.svg" alt="Wanderplan Logo" height="40" class="me-2" />
          </a>
      </div>
      <!-- Hamburger for mobile -->
      <button
        class="d-md-none btn p-2"
        @click="drawerOpen = !drawerOpen"
        aria-label="Open menu"
      >
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
          xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
          <rect y="4" width="24" height="2" rx="1" fill="#333"/>
          <rect y="11" width="24" height="2" rx="1" fill="#333"/>
          <rect y="18" width="24" height="2" rx="1" fill="#333"/>
        </svg>
      </button>
      <!-- Desktop nav -->
      <nav class="d-none d-md-flex align-items-center gap-3">
        <a href="#" class="text-dark text-decoration-none">About us</a>
        <a href="#" class="text-dark text-decoration-none">Guides</a>
        <button v-if="!isLoggedIn" @click="showLoginDrawer = true" class="btn-orange px-3 py-1">Sign In</button>
        <button v-else @click="showProfileDrawer = true" class="btn-orange px-3 py-1">Profile</button>      </nav>
    </div>
    <!-- Side drawer for mobile -->
    <transition name="slide">
      <div
        v-if="drawerOpen"
        class="side-drawer d-md-none"
        @click.self="drawerOpen = false"
      >
        <div class="drawer-content">
          <button class="btn-close mb-4" @click="drawerOpen = false"></button>
          <a href="#" class="d-block mb-3 text-dark text-decoration-none">About us</a>
          <a href="#" class="d-block mb-3 text-dark text-decoration-none">Guides</a>

        <button v-if="!isLoggedIn" @click="showLoginDrawer = true" class="btn-orange px-3 py-1">Sign In</button>
        <button v-else @click="showProfileDrawer = true" class="btn-orange px-3 py-1">Profile</button>        </div>
      </div>
    </transition>
  </header>
  <LoginRegisterDrawer
    :show="showLoginDrawer"
    @close="showLoginDrawer = false"
    @authenticated="showLoginDrawer = false"
  />
  <ProfileDrawer
    :show="showProfileDrawer"
    @close="showProfileDrawer = false"
    @logout="logout"
  />
</template>

<script setup>
import { ref, watch } from 'vue'
import LoginRegisterDrawer from '@/components/auth/LoginRegisterDrawer.vue'
import { useAuthState } from '@/composables/useAuthState'
import ProfileDrawer from '@/components/auth/ProfileDrawer.vue'

const { isLoggedIn, login, logout } = useAuthState()

const drawerOpen = ref(false)
const showLoginDrawer = ref(false)
// const userLoggedIn = ref(false)
const showProfileDrawer = ref(false)

// watch(showLoginDrawer, (val) => {
//   console.log('showLoginDrawer changed:', val)
// })

// watch(isLoggedIn, (val) => {
//   console.log('isLoggedIn changed:', val)
// })
</script>

<style scoped>
.side-drawer {
  position: fixed;
  top: 0;
  right: 0;
  width: 75vw;
  max-width: 320px;
  height: 100vh;
  background: #fff;
  box-shadow: -2px 0 16px rgba(0,0,0,0.12);
  z-index: 1050;
  display: flex;
  flex-direction: column;
  padding: 2rem 1.5rem;
  transition: transform 0.3s;
}
.slide-enter-from,
.slide-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
.slide-enter-to,
.slide-leave-from {
  transform: translateX(0);
  opacity: 1;
}
.drawer-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}
</style>
