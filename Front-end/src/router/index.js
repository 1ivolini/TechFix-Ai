
import { createRouter, createWebHistory } from 'vue-router'

import CadastroView from '../views/CadastroView.vue'
import HomeView from '../views/HomeView.vue'
import LoginView from '../views/LoginView.vue'
import SimulacaoView from '../views/SimulacaoView.vue'
import { useAuth } from '../composables/useAuth.js'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: {
      guestOnly: true
    }
  },
  {
    path: '/cadastro',
    name: 'cadastro',
    component: CadastroView,
    meta: {
      guestOnly: true
    }
  },
  {
  path: '/simulacao/:tentativaId/:cenarioId',
  name: 'simulacao',
  component: SimulacaoView,
  meta: {
    requiresAuth: true
  }
}
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Verificar autenticação antes de navegar.
router.beforeEach((to) => {
  const { autenticado } = useAuth()

  // Impedir que usuários não autenticados
  // acessem páginas protegidas.
  if (to.meta.requiresAuth && !autenticado.value) {
    return { name: 'login' }
  }

  // Impedir que usuários autenticados
  // acessem novamente login e cadastro.
  if (to.meta.guestOnly && autenticado.value) {
    return { name: 'home' }
  }
}
)

export default router
