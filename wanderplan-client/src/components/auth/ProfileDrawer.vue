<template>


  <div v-if="show" class="drawer-overlay" @click.self="close">
    <div class="drawer">
      <div class="d-flex justify-content-end mb-5">
        <button class="close-btn" @click="close">&times;</button>
      </div>
      <div v-if="loading">Loading...</div>
      <div v-else>

      </div>
      <div class="user-area">
        <span class="round-avatar"><UserInfo info="initials" /></span>
        <small><UserInfo info="email" /></small>
      </div>
      <ul class="list-group py-2">
        <li v-for="item in menuLinks" :key="item.name" class="menu-item">
          <button
            type="button"
            class="btn w-100 text-start"
            @click="$router.push(item.route)"
          >
            <component :is="item.icon" class="me-2" v-if="item.icon" />
            {{ item.name }}
          </button>
        </li>
        <li class="logout-item menu-item">

          <button class="btn w-100 text-start text-danger" @click="handleLogout">
            <component :is="LogOut" class="me-2" />
            Logout
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useAuthState } from '@/composables/useAuthState'
import { Heart, Briefcase, CircleUser, LogOut } from 'lucide-vue-next'
import UserInfo from '@/components/widgets/UserInfo.vue'
// Menu links
const menuLinks = [
  {
    name: 'My Profile',
    icon: CircleUser,
    route: '/profile'
  },
    {
      name: 'My Trips',
    icon: Heart,
    route: '/trips'
  },
  {
    name: 'My Bookings',
    icon: Briefcase,
    route: '/bookings'
  }
  ]
const props = defineProps({ show: Boolean })
const emit = defineEmits(['close', 'logout'])

function close() {
  emit('close')
}
function handleLogout() {
  useAuthState().logout()
  emit('logout')
  close()
}

const user = ref(null)

onMounted(async () => {
  try {
    const res = await axios.get('http://localhost:3000/api/v1/me', {
      withCredentials: true
    })
    user.value = res.data
  } catch {
    user.value = null
  }
})
async function fetchUserInfo() {
  try {
    const res = await axios.get('http://localhost:3000/api/v1/me', {
      withCredentials: true // needed for cookies/session
    })
    // The user info is in res.data
    return res.data
  } catch (err) {
    return null
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
  display: flex; flex-direction: column;
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
.menu-item {
  margin-bottom: 1rem;
  display: block;
  align-items: center;
  padding-bottom: 1rem;
  padding-top: 1rem;
  margin-bottom: 0px;
}
.menu-item:hover {
  background: #f8f8f8;
}
.menu-item:first-child {
  border-top: 1px solid;
  border-bottom: 1px solid;
  border-color:#e9e9e9 ;
}
.logout-item {
  border-top: 1px solid;
  border-bottom: 1px solid;
  border-color:#e9e9e9 ;
  text-decoration: none;
}
.round-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: #f3f3f3;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  font-weight: 600;
  color: #333;
  border: #cecece 1px solid;
  margin: 0 auto 1rem auto;
  box-shadow: 0 2px 8px rgba(0,0,0,0.07);
  overflow: hidden;
}
.round-avatar > * {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
}
.user-area {
  text-align: center;
}

</style>
