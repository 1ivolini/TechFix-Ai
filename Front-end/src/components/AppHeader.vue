
<script setup>
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth.js'

defineProps({
  nomeSistema: {
    type: String,
    default: 'TECHFIX AI'
  }
})

const router = useRouter()

const {
  autenticado,
  usuario,
  encerrarSessao
} = useAuth()

function sair() {
  encerrarSessao()
  router.push('/login')
}
</script>

<template>
  <header class="cabecalho">
    <div class="cabecalho-conteudo">

      <RouterLink class="marca" to="/" aria-label="TECHFIX AI - início">
        <span class="marca-icone">TF</span>

        <span class="marca-texto">
          <strong>{{ nomeSistema }}</strong>
          <small>Aprendizado em informática</small>
        </span>
      </RouterLink>

      <nav class="cabecalho-navegacao">

        <RouterLink
          to="/"
          class="navegacao-link"
          exact-active-class="rota-ativa"
        >
          Início
        </RouterLink>

        <template v-if="!autenticado">

          <RouterLink
            to="/login"
            class="navegacao-link"
          >
            Entrar
          </RouterLink>

          <RouterLink
            to="/cadastro"
            class="navegacao-link navegacao-destaque"
          >
            Criar conta
          </RouterLink>

        </template>

        <template v-else>

          <span class="usuario-saudacao">
            Olá, {{ usuario?.nome_usuario || 'Usuário' }}
          </span>

          <button
            type="button"
            class="navegacao-link navegacao-sair"
            @click="sair"
          >
            Sair
          </button>

        </template>

      </nav>

    </div>
  </header>
</template>
