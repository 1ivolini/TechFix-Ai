
<script setup>
import { ref, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth.js'

const router = useRouter()

const {
  cadastrar,
  login,
  carregando,
  erro,
  limparErro
} = useAuth()

const nome = ref('')
const nome_usuario = ref('')
const email = ref('')
const senha = ref('')
const confirmarSenha = ref('')

const mensagemSucesso = ref('')
const erroValidacao = ref('')
const erroLoginAutomatico = ref('')
const autenticandoAposCadastro = ref(false)
const redirecionando = ref(false)

let timerRedirecionamento = null

async function enviarCadastro() {
  limparErro()

  mensagemSucesso.value = ''
  erroValidacao.value = ''
  erroLoginAutomatico.value = ''
  autenticandoAposCadastro.value = false
  redirecionando.value = false

  if (senha.value !== confirmarSenha.value) {
    erroValidacao.value = 'As senhas não coincidem.'
    return
  }

  const credenciais = {
    nome_usuario: nome_usuario.value.trim(),
    senha: senha.value
  }

  try {
    // Primeiro: cadastrar o usuário.
    const resultado = await cadastrar({
      nome: nome.value.trim(),
      ...credenciais,
      email: email.value.trim()
    })

    mensagemSucesso.value =
      resultado.mensagem || 'Cadastro realizado com sucesso!'

    // Segundo: realizar o login automaticamente.
    autenticandoAposCadastro.value = true

    try {
      await login(credenciais)

      autenticandoAposCadastro.value = false
      redirecionando.value = true

      // Terceiro: redirecionar para o menu principal.
      timerRedirecionamento = window.setTimeout(() => {
        router.replace('/')
      }, 1500)

    } catch (loginError) {
      console.error('Erro no login automático:', loginError)

      autenticandoAposCadastro.value = false

      erroLoginAutomatico.value =
        'Sua conta foi criada, mas não foi possível realizar o acesso automático. Entre utilizando suas credenciais.'
    }

  } catch (error) {
    console.error('Erro ao cadastrar usuário:', error)
  }
}

// Limpar o temporizador caso o componente seja desmontado.
onUnmounted(() => {
  if (timerRedirecionamento !== null) {
    clearTimeout(timerRedirecionamento)
  }
})
</script>

<template>
  <main class="login-layout">

    <!-- Painel de identidade visual -->
    <section class="login-visual">

      <div class="login-marca">
        <div class="login-marca-icone">TF</div>

        <div class="login-marca-texto">
          <strong>TECHFIX <span>AI</span></strong>
          <small>Aprendizado em informática</small>
        </div>
      </div>

      <div class="login-apresentacao">
        <span class="login-etiqueta">COMECE SUA JORNADA</span>

        <h1>
          Conhecimento.
          <span>Prática.</span>
          Evolução.
        </h1>

        <p>
          Crie sua conta e desenvolva suas habilidades
          em montagem e manutenção de computadores.
        </p>

        <div class="login-ilustracao" aria-hidden="true">
          <svg
            viewBox="0 0 220 160"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect
              x="60" y="15"
              width="100" height="105"
              rx="10"
              stroke="#60A5FA"
              stroke-width="3"
            />

            <rect
              x="70" y="25"
              width="80" height="85"
              rx="5"
              fill="#1E3A6D"
            />

            <rect
              x="88" y="43"
              width="44" height="44"
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
          </svg>
        </div>
      </div>

      <div class="login-assinatura">
        Aprender, investigar e evoluir.
      </div>

    </section>

    <!-- Área de cadastro -->
    <section class="login-area">

      <div class="login-card cadastro-card">

        <!-- Formulário exibido antes do cadastro -->
        <template v-if="!mensagemSucesso">

          <div class="login-cabecalho">
            <span class="login-etiqueta-clara">
              CRIAR CONTA
            </span>

            <h2>Crie sua conta!</h2>

            <p>
              Preencha seus dados para começar a utilizar
              o TECHFIX AI.
            </p>
          </div>

          <form @submit.prevent="enviarCadastro">

            <div class="login-campo">
              <label for="nome">Nome completo</label>

              <input
                id="nome"
                v-model="nome"
                type="text"
                placeholder="Digite seu nome completo"
                maxlength="100"
                autocomplete="name"
                required
                @input="limparErro"
              />
            </div>

            <div class="login-campo">
              <label for="nome_usuario">Nome de usuário</label>

              <input
                id="nome_usuario"
                v-model="nome_usuario"
                type="text"
                placeholder="Escolha um nome de usuário"
                minlength="3"
                maxlength="50"
                autocomplete="username"
                required
                @input="limparErro"
              />
            </div>

            <div class="login-campo">
              <label for="email">E-mail</label>

              <input
                id="email"
                v-model="email"
                type="email"
                placeholder="Digite seu e-mail"
                maxlength="150"
                autocomplete="email"
                required
                @input="limparErro"
              />
            </div>

            <div class="login-campo">
              <label for="senha">Senha</label>

              <input
                id="senha"
                v-model="senha"
                type="password"
                placeholder="Mínimo de 8 caracteres"
                minlength="8"
                autocomplete="new-password"
                required
                @input="limparErro"
              />
            </div>

            <div class="login-campo">
              <label for="confirmarSenha">Confirmar senha</label>

              <input
                id="confirmarSenha"
                v-model="confirmarSenha"
                type="password"
                placeholder="Digite sua senha novamente"
                minlength="8"
                autocomplete="new-password"
                required
              />
            </div>

            <p
              v-if="erro || erroValidacao"
              class="login-erro"
              role="alert"
            >
              {{ erro || erroValidacao }}
            </p>

            <button
              type="submit"
              class="login-botao"
              :disabled="carregando"
            >
              <span
                v-if="carregando"
                class="login-spinner"
              ></span>

              {{ carregando ? 'Cadastrando...' : 'Criar minha conta' }}

              <span v-if="!carregando">→</span>
            </button>

          </form>

          <div class="login-divisor">
            <span>TECHFIX AI</span>
          </div>

          <div class="login-navegacao">
            <RouterLink to="/" class="login-voltar">
              ← Página inicial
            </RouterLink>

            <RouterLink to="/login" class="login-cadastro-link">
              Já possui uma conta? Entrar
            </RouterLink>
          </div>

          <p class="login-rodape">
            Aprenda, pratique e evolua no seu ritmo.
          </p>

        </template>

        <!-- Tela exibida após o cadastro -->
        
<div
  v-else
  class="cadastro-sucesso"
  role="status"
>
  <div class="cadastro-sucesso-icone">
    ✓
  </div>

  <span class="login-etiqueta-clara">
    CADASTRO CONCLUÍDO
  </span>

  <h3>Cadastro realizado com sucesso!</h3>

  <p v-if="autenticandoAposCadastro">
    Estamos autenticando sua conta...
  </p>

  <p v-else-if="redirecionando">
    Seu acesso foi confirmado! Você será direcionado
    ao menu principal do TECHFIX AI.
  </p>

  <template v-else-if="erroLoginAutomatico">

    <p>
      Sua conta foi criada, mas o acesso automático
      não pôde ser concluído.
    </p>

    <p class="login-erro">
      {{ erroLoginAutomatico }}
    </p>

    <RouterLink
      to="/login"
      class="login-botao cadastro-link"
    >
      Acessar minha conta →
    </RouterLink>

  </template>
</div>


      </div>

    </section>

  </main>
</template>
