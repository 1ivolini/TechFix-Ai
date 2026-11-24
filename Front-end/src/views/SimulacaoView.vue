<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import {
  consultarCenario,
  listarCenarios
} from '../services/cenarioService.js'

import { useTentativas } from '../composables/useTentativas.js'

const route = useRoute()
const router = useRouter()

const tentativaId = computed(() => route.params.tentativaId)
const cenarioId = computed(() => route.params.cenarioId)

// Gerenciamento das tentativas.
const {
  iniciarTentativa,
  registrarAcao,
  registrandoAcao,
  acoesRegistradas
} = useTentativas()
// Estados da navegação entre os casos.
const carregandoProximoCaso = ref(false)
const mensagemNavegacao = ref('')
// Dados do cenário.
const cenario = ref(null)
const acoes = ref([])

// Estados da consulta.
const carregando = ref(false)
const erro = ref('')

// Estados das ações.
const resultadoAcao = ref(null)
const erroAcao = ref('')
// Identificar a imagem correspondente ao cenário.
const imagemCenario = computed(() => {
  if (!cenario.value?.titulo) return null

  const titulo = cenario.value.titulo
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()

  // 1. Computador desliga sozinho.
  if (titulo.includes('desliga sozinho')) {
    return '/images/casos/caso-computador-reinicia-sozinho.png'
  }

  // 2. Computador lento.
  if (titulo.includes('computador lento')) {
    return '/images/casos/caso-computador-reinicia-sozinho.png'
  }

  // 3. Superaquecimento do computador.
  if (titulo.includes('superaquecimento')) {
    return '/images/casos/caso-superaquecimento.png'
  }

  // 4. Computador não liga.
  if (titulo.includes('nao liga')) {
    return '/images/casos/caso-computador-reinicia-sozinho.png'
  }

  // Cenários anteriores, caso ainda sejam utilizados.
  if (titulo.includes('reinicia')) {
    return '/images/casos/caso-computador-reinicia-sozinho.png'
  }

  if (titulo.includes('video')) {
    return '/images/casos/caso-computador-reinicia-sozinho.png'
  }

  return null
})

// Consultar os dados do cenário no Flask.
async function carregarCenario() {
  carregando.value = true
  erro.value = ''

  try {
    const resultado = await consultarCenario(cenarioId.value)

    cenario.value = resultado.cenario
    acoes.value = resultado.acoes

  } catch (error) {
    console.error('Erro ao carregar cenário:', error)

    erro.value =
      error.message || 'Não foi possível carregar o cenário.'

  } finally {
    carregando.value = false
  }
}

// Registrar uma ação realizada pelo aluno.
async function investigarAcao(acao) {
  erroAcao.value = ''
  resultadoAcao.value = null

  try {
    const resultado = await registrarAcao(
      tentativaId.value,
      acao.id
    )

    resultadoAcao.value = resultado

  } catch (error) {
    console.error('Erro ao registrar ação:', error)

    erroAcao.value =
      error.message || 'Não foi possível registrar a ação.'
  }
}

// Carregar os dados quando a tela for aberta.
// Atualizar a tela quando o cenário ou a tentativa mudar.
watch(
  () => [
    route.params.tentativaId,
    route.params.cenarioId
  ],
  () => {
    resultadoAcao.value = null
    erroAcao.value = ''
    mensagemNavegacao.value = ''

    carregarCenario()
  },
  { immediate: true }
)
// Abrir o próximo estudo de caso.
async function irParaProximoCaso() {
  if (carregandoProximoCaso.value) return

  carregandoProximoCaso.value = true
  mensagemNavegacao.value = ''

  try {
    // Consultar os cenários disponíveis.
    const resposta = await listarCenarios()

    const listaCenarios = Array.isArray(resposta)
      ? resposta
      : resposta.cenarios || []

    // Identificar a posição do cenário atual.
    const indiceAtual = listaCenarios.findIndex(
      item => Number(item.id) === Number(cenarioId.value)
    )

    if (indiceAtual === -1) {
      throw new Error('Não foi possível identificar o estudo de caso atual.')
    }

    // Selecionar o próximo cenário.
    const proximoCenario = listaCenarios[indiceAtual + 1]

    if (!proximoCenario) {
      mensagemNavegacao.value =
        'Você chegou ao último estudo de caso disponível!'
      return
    }

    // Criar uma nova tentativa para o próximo caso.
    const novaTentativa = await iniciarTentativa(
      proximoCenario.id
    )

    // Abrir o próximo estudo de caso.
    await router.push({
      name: 'simulacao',
      params: {
        tentativaId: novaTentativa.tentativa_id,
        cenarioId: proximoCenario.id
      }
    })

  } catch (error) {
    console.error('Erro ao avançar para o próximo caso:', error)

    mensagemNavegacao.value =
      error.message || 'Não foi possível abrir o próximo caso.'

  } finally {
    carregandoProximoCaso.value = false
  }
}
</script>

<template>
  <main class="simulacao-pagina">

    <div class="simulacao-conteudo">
      <!-- Navegação entre os estudos de caso -->
<!-- Navegação principal -->
<nav class="simulacao-navegacao">

  <div class="nav-esquerda">
    <RouterLink to="/" class="botao-voltar-menu">
      ← Voltar ao menu
    </RouterLink>
  </div>

  <div class="nav-identidade">
    <span class="nav-logo">TECHFIX AI</span>
    <span class="nav-descricao">Área de aprendizado</span>
  </div>

  <div class="nav-direita">
    <button
      type="button"
      class="botao-proximo-caso"
      :disabled="carregandoProximoCaso || registrandoAcao"
      @click="irParaProximoCaso"
    >
      {{
        carregandoProximoCaso
          ? 'Abrindo...'
          : 'Próximo caso →'
      }}
    </button>
  </div>

</nav>

<p
  v-if="mensagemNavegacao"
  class="mensagem-navegacao"
  role="status"
>
  {{ mensagemNavegacao }}
</p>
      <!-- Identificação do sistema -->
      

      <!-- Carregamento -->
      <div v-if="carregando" class="estado-pagina">
        <h1>Preparando seu desafio...</h1>
        <p>Estamos organizando as informações do estudo de caso.</p>
      </div>

      <!-- Erro ao carregar -->
      <div v-else-if="erro" class="estado-pagina">
        <h1>Não foi possível carregar o desafio.</h1>
        <p>{{ erro }}</p>

        <button
          type="button"
          class="botao-investigar"
          @click="carregarCenario"
        >
          Tentar novamente
        </button>
      </div>

      <!-- Conteúdo do cenário -->
      <template v-else-if="cenario">

        <!-- Apresentação do estudo de caso -->
        <section class="caso-apresentacao">

          <div class="caso-texto">

            <span class="caso-selo">
              Estudo de caso
            </span>

            <span
              v-if="cenario.categoria"
              class="caso-categoria"
            >
              {{ cenario.categoria }}
            </span>

            <h1>{{ cenario.titulo }}</h1>

            <p class="caso-descricao">
              {{ cenario.descricao }}
            </p>

            <div class="caso-missao">
              <strong>Sua missão</strong>

              <p>
                Investigue as opções disponíveis e descubra
                o que pode estar causando esse problema.
              </p>
            </div>

            <span
              v-if="cenario.dificuldade"
              class="caso-dificuldade"
            >
              Nível do desafio: {{ cenario.dificuldade }}
            </span>

          </div>

          <!-- Imagem ilustrativa -->
          <div class="caso-imagem">

            <img
              v-if="imagemCenario"
              :src="imagemCenario"
              :alt="`Ilustração: ${cenario.titulo}`"
            />

            <div v-else class="caso-imagem-indisponivel">
              <span>Ilustração do desafio</span>
              <p>
                Uma imagem para este estudo de caso será adicionada em breve.
              </p>
            </div>

          </div>

        </section>

        <!-- Investigação -->
        <section class="simulacao-secao investigacao-secao">

          <div class="secao-titulo">
            <h2>Vamos investigar?</h2>

            <p>
              Escolha uma opção para começar a descobrir o que aconteceu.
            </p>
          </div>

          <div
            v-if="acoes.length"
            class="investigacao-lista"
          >

            <article
              v-for="acao in acoes"
              :key="acao.id"
              class="investigacao-card"
            >

              <div class="investigacao-texto">
                <h3>{{ acao.descricao }}</h3>
              </div>

              <button
                type="button"
                class="botao-investigar"
                :disabled="registrandoAcao"
                @click="investigarAcao(acao)"
              >
                {{
                  registrandoAcao
                    ? 'Investigando...'
                    : 'Investigar'
                }}
              </button>

            </article>

          </div>

          <p v-else class="mensagem-vazia">
            Nenhuma opção de investigação está disponível neste momento.
          </p>

          <!-- Erro ao investigar -->
          <div
            v-if="erroAcao"
            class="resultado-acao resultado-erro"
            role="alert"
          >
            {{ erroAcao }}
          </div>

          <!-- Resultado da investigação -->
          <div
            v-if="resultadoAcao"
            class="resultado-acao"
            role="status"
          >

            <h3>O que você descobriu?</h3>

            <p>{{ resultadoAcao.resultado }}</p>

            <p>
              {{
                resultadoAcao.relevante
                  ? 'Essa investigação trouxe uma pista importante!'
                  : 'Essa investigação não ajudou diretamente a identificar o problema. Continue tentando!'
              }}
            </p>

            <div class="resultado-pontos">
              <span>Pontos conquistados</span>

              <strong>
                +{{ resultadoAcao.pontos_obtidos }} pontos
              </strong>
            </div>

          </div>

        </section>

        <!-- Histórico da investigação -->
        <section
          v-if="acoesRegistradas.length"
          class="simulacao-secao historico-secao"
        >

          <h2>Suas investigações</h2>

          <div class="historico-lista">

            <article
              v-for="(registro, indice) in acoesRegistradas"
              :key="registro.registro_id || indice"
              class="historico-item"
            >

              <span>
                {{ registro.acao }}
              </span>

              <strong>
                +{{ registro.pontos_obtidos }} pontos
              </strong>

            </article>

          </div>

        </section>

      </template>

   
    </div>

  </main>
</template>