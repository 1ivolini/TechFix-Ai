
<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

import { consultarCenario } from '../services/cenarioService.js'
import { useTentativas } from '../composables/useTentativas.js'

const route = useRoute()

const tentativaId = route.params.tentativaId
const cenarioId = route.params.cenarioId

// Gerenciamento das tentativas.
const {
  registrarAcao,
  registrandoAcao,
  acoesRegistradas
} = useTentativas()

// Dados do cenário.
const cenario = ref(null)
const acoes = ref([])
const dicas = ref([])
const diagnosticos = ref([])

// Estados da consulta.
const carregando = ref(false)
const erro = ref('')

// Estados das ações.
const resultadoAcao = ref(null)
const erroAcao = ref('')

// Consultar os dados do cenário no Flask.
async function carregarCenario() {
  carregando.value = true
  erro.value = ''

  try {
    const resultado = await consultarCenario(cenarioId)

    cenario.value = resultado.cenario
    acoes.value = resultado.acoes
    dicas.value = resultado.dicas
    diagnosticos.value = resultado.diagnosticos

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
      tentativaId,
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
onMounted(() => {
  carregarCenario()
})
</script>

<template>
  <main class="simulacao-pagina">

    <div class="simulacao-conteudo">

      <span class="simulacao-etiqueta">
        TECHFIX AI · ÁREA DE SIMULAÇÃO
      </span>

      <!-- Carregamento -->
      <div v-if="carregando">
        <h1>Preparando seu desafio...</h1>
        <p>Buscando as informações do cenário.</p>
      </div>

      <!-- Erro -->
      <div v-else-if="erro">
        <h1>Não foi possível carregar o desafio.</h1>
        <p>{{ erro }}</p>

        <button
          type="button"
          @click="carregarCenario"
        >
          Tentar novamente
        </button>
      </div>

      <!-- Dados do cenário -->
      <template v-else-if="cenario">

        <div class="simulacao-cabecalho">

          <span class="simulacao-categoria">
            {{ cenario.categoria }}
          </span>

          <h1>{{ cenario.titulo }}</h1>

          <p>{{ cenario.descricao }}</p>

          <div class="simulacao-informacoes">
            <span>
              <strong>Tentativa:</strong>
              {{ tentativaId }}
            </span>

            <span>
              <strong>Dificuldade:</strong>
              {{ cenario.dificuldade }}
            </span>
          </div>

        </div>

        <!-- Ações disponíveis -->
        <section class="simulacao-secao">

          <h2>Ações disponíveis</h2>

          <p>
            Escolha quais elementos deseja investigar
            para identificar a origem do problema.
          </p>

          <div v-if="acoes.length" class="simulacao-lista">

            <article
              v-for="acao in acoes"
              :key="acao.id"
              class="simulacao-item"
            >
              <span>{{ acao.descricao }}</span>

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

          <p v-else>
            Nenhuma ação disponível para este cenário.
          </p>

          <!-- Erro ao registrar ação -->
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

            <h3>Resultado da investigação</h3>

            <p>{{ resultadoAcao.resultado }}</p>

            <p>
              <strong>Relevância:</strong>

              {{
                resultadoAcao.relevante
                  ? 'Ação relevante'
                  : 'Ação não relevante'
              }}
            </p>

            <p>
              <strong>Pontos obtidos:</strong>
              {{ resultadoAcao.pontos_obtidos }}
            </p>

          </div>

        </section>

        <!-- Histórico das ações -->
        <section
          v-if="acoesRegistradas.length"
          class="simulacao-secao"
        >
          <h2>Histórico da investigação</h2>

          <div class="simulacao-lista">

            <article
              v-for="(registro, indice) in acoesRegistradas"
              :key="registro.registro_id || indice"
              class="simulacao-item"
            >
              <span>{{ registro.acao }}</span>

              <strong>
                +{{ registro.pontos_obtidos }} pontos
              </strong>
            </article>

          </div>
        </section>

        <!-- Dicas disponíveis -->
        <section class="simulacao-secao">

          <h2>Dicas disponíveis</h2>

          <p>
            Você poderá solicitar dicas durante sua investigação.
          </p>

          <div class="simulacao-lista">

            <article
              v-for="dica in dicas"
              :key="dica.id"
              class="simulacao-item"
            >
              Dica nível {{ dica.nivel }}
            </article>

          </div>

        </section>

        <!-- Diagnósticos possíveis -->
        <section class="simulacao-secao">

          <h2>Diagnósticos possíveis</h2>

          <p>
            Ao concluir sua investigação, escolha o diagnóstico
            que melhor explica o problema.
          </p>

          <div class="simulacao-lista">

            <article
              v-for="diagnostico in diagnosticos"
              :key="diagnostico.id"
              class="simulacao-item"
            >
              {{ diagnostico.descricao }}
            </article>

          </div>

        </section>

      </template>

      <RouterLink to="/" class="simulacao-voltar">
        ← Voltar ao menu principal
      </RouterLink>

    </div>

  </main>
</template>
