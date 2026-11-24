
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth.js'

const router = useRouter()

const { login, carregando, erro, limparErro } = useAuth()

const nome_usuario = ref('')
const senha = ref('')
const mostrarSenha = ref(false)

async function enviarLogin() {
  limparErro()

  try {
    await login({
      nome_usuario: nome_usuario.value.trim(),
      senha: senha.value
    })

    router.push('/')
  } catch (error) {
    console.error('Erro ao realizar login:', error)
  }
}
</script>

<template>
  <main class="login-layout">

    <!-- Painel de identidade visual -->
    <section class="login-visual">

      <div class="login-marca">
        <div class="login-marca-icone">
          TF
        </div>

        <div class="login-marca-texto">
          <strong>TECHFIX <span>AI</span></strong>
          <small>Aprendizado em informática</small>
        </div>
      </div>

      <div class="login-apresentacao">
        <span class="login-etiqueta">APRENDA FAZENDO</span>

        <h1>
          Aprenda.
          <span>Pratique.</span>
          Evolua.
        </h1>

        <p>
          Desenvolva suas habilidades em montagem e manutenção
          de computadores por meio de desafios interativos.
        </p>

        <div class="login-ilustracao" aria-hidden="true">
          <svg
            viewBox="0 0 220 160"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect
              x="60"
              y="15"
              width="100"
              height="105"
              rx="10"
              stroke="#60A5FA"
              stroke-width="3"
            />

            <rect
              x="70"
              y="25"
              width="80"
              height="85"
              rx="5"
              fill="#1E3A6D"
            />

            <rect
              x="88"
              y="43"
              width="44"
              height="44"
              rx="8"
              stroke="#38BDF8"
              stroke-width="3"
            />

            <path
              d="M110 51V79M96 65H124"
              stroke="#60A5FA"
              stroke-width="3"
              stroke-linecap="round"
            />

            <path
              d="M45 135H175L160 120H60L45 135Z"
              fill="#2563EB"
              stroke="#60A5FA"
              stroke-width="2"
            />

            <path
              d="M25 43H48M25 65H48M25 87H48M172 43H195M172 65H195M172 87H195"
              stroke="#60A5FA"
              stroke-width="2"
              stroke-linecap="round"
            />

            <circle cx="25" cy="43" r="3" fill="#38BDF8"/>
            <circle cx="25" cy="65" r="3" fill="#38BDF8"/>
            <circle cx="25" cy="87" r="3" fill="#38BDF8"/>
            <circle cx="195" cy="43" r="3" fill="#38BDF8"/>
            <circle cx="195" cy="65" r="3" fill="#38BDF8"/>
            <circle cx="195" cy="87" r="3" fill="#38BDF8"/>
          </svg>
        </div>
      </div>

      <div class="login-beneficios">
        <span>Desafios práticos</span>
        <span>Aprendizado progressivo</span>
        <span>Conhecimento em TI</span>
      </div>

      <div class="login-assinatura">
        Aprender, investigar e evoluir.
      </div>

    </section>

    <!-- Área do formulário -->
    <section class="login-area">

      <div class="login-card">

        <div class="login-cabecalho">
          <span class="login-etiqueta-clara">ACESSO À PLATAFORMA</span>

          <h2>Bem-vindo de volta!</h2>

          <p>
            Entre na sua conta para continuar aprendendo.
          </p>
        </div>

        <form @submit.prevent="enviarLogin">

          <div class="login-campo">
            <label for="nome_usuario">
              Nome de usuário
            </label>

            <input
              id="nome_usuario"
              v-model="nome_usuario"
              type="text"
              placeholder="Digite seu nome de usuário"
              autocomplete="username"
              required
              @input="limparErro"
            />
          </div>

          <div class="login-campo">
            <label for="senha">
              Senha
            </label>

            <div class="login-senha-wrapper">
              <input
                id="senha"
                v-model="senha"
                :type="mostrarSenha ? 'text' : 'password'"
                placeholder="Digite sua senha"
                autocomplete="current-password"
                required
                @input="limparErro"
              />

              <button
                type="button"
                class="login-mostrar-senha"
                @click="mostrarSenha = !mostrarSenha"
                :aria-pressed="mostrarSenha"
                :aria-label="mostrarSenha ? 'Ocultar senha' : 'Mostrar senha'"
              >
                {{ mostrarSenha ? 'Ocultar' : 'Mostrar' }}
              </button>
            </div>
          </div>

          <p
            v-if="erro"
            class="login-erro"
            role="alert"
          >
            {{ erro }}
          </p>

          <button
            type="submit"
            class="login-botao"
            :disabled="carregando"
          >
            <span v-if="carregando" class="login-spinner"></span>

            {{ carregando ? 'Entrando...' : 'Entrar' }}

            <span v-if="!carregando" aria-hidden="true">→</span>
          </button>

        </form>

        <div class="login-divisor">
          <span>TECHFIX AI</span>
        </div>

       <div class="login-navegacao">
  <RouterLink to="/" class="login-voltar">
    ← Página inicial
  </RouterLink>

  <RouterLink to="/cadastro" class="login-cadastro-link">
    Não possui conta? Cadastre-se
  </RouterLink>
</div>

        <p class="login-rodape">
          Aprenda, pratique e evolua no seu ritmo.
        </p>

      </div>

    </section>

  </main>
</template>
