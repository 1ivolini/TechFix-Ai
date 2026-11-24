
<script setup>
defineProps({
  cenarios: {
    type: Array,
    default: () => []
  },
  carregando: {
    type: Boolean,
    default: false
  },
  erro: {
    type: String,
    default: ''
  },
  mostrarCenarios: {
    type: Boolean,
    default: false
  },
    tentativa: {
    type: Object,
    default: null
  },

  iniciandoTentativa: {
    type: Boolean,
    default: false
  },

  erroTentativa: {
    type: String,
    default: ''
  }
})

const emit = defineEmits([
  'tentar-novamente',
  'iniciar-desafio'
])

function formatarDificuldade(dificuldade) {
  const niveis = {
    facil: 'Fácil',
    medio: 'Médio',
    dificil: 'Difícil'
  }

  return niveis[dificuldade?.toLowerCase()] || dificuldade || 'Não informada'
}
</script>

<template>
  <section id="cenarios" class="secao-cenarios">

    <div class="secao-cabecalho">
      <div>
        <span class="sobretitulo">DESAFIOS PRÁTICOS</span>
        <h2>Escolha seu cenário</h2>
        <p>
          Investigue os problemas e descubra as possíveis causas.
        </p>
      </div>

      <span class="contador" v-if="cenarios.length">
        {{ cenarios.length }}
        {{ cenarios.length === 1 ? 'cenário' : 'cenários' }}
      </span>
    </div>

    <!-- Estado inicial -->
    <div v-if="!mostrarCenarios" class="estado-inicial">
      <div class="estado-icone">⌕</div>
      <strong>Seu próximo desafio começa aqui</strong>
      <p>
        Clique em “Explorar cenários” para visualizar os desafios disponíveis.
      </p>
    </div>

    <!-- Carregamento dos cenários -->
    <div v-else-if="carregando" class="estado-inicial">
      <div class="carregando-icone"></div>
      <strong>Preparando seus desafios...</strong>
      <p>Buscando os cenários disponíveis.</p>
    </div>

    <!-- Erro ao carregar cenários -->
    <div v-else-if="erro" class="estado-inicial estado-erro">
      <div class="estado-icone">!</div>
      <strong>Não foi possível carregar os cenários</strong>
      <p>{{ erro }}</p>

      <button
        type="button"
        class="botao-secundario"
        @click="emit('tentar-novamente')"
      >
        Tentar novamente
      </button>
    </div>

    <!-- Nenhum cenário disponível -->
    <div v-else-if="cenarios.length === 0" class="estado-inicial">
      <div class="estado-icone">⌕</div>
      <strong>Nenhum cenário disponível</strong>
      <p>Novos desafios poderão aparecer aqui quando forem cadastrados.</p>
    </div>

    <!-- Listagem dos cenários -->
    <div v-else class="lista-cenarios">

      <article
        v-for="(cenario, indice) in cenarios"
        :key="cenario.id"
        class="card-cenario"
      >
        <div class="card-topo">
          <span class="categoria">
            {{ cenario.categoria }}
          </span>

          <span class="numero-cenario">
            {{ String(indice + 1).padStart(2, '0') }}
          </span>
        </div>

        <h3>{{ cenario.titulo }}</h3>

        <p class="card-descricao">
          {{ cenario.descricao }}
        </p>

        <div class="card-rodape">
          <span class="nivel">
            <span class="nivel-ponto"></span>
            {{ formatarDificuldade(cenario.dificuldade) }}
          </span>

          <span class="tipo-desafio">
            Desafio técnico
          </span>
        </div>

        <!-- Botão para iniciar desafio -->
        <button
          type="button"
          class="botao-iniciar-desafio"
          :disabled="iniciandoTentativa"
          @click="emit('iniciar-desafio', cenario.id)"
        >
          {{
            iniciandoTentativa
              ? 'Iniciando desafio...'
              : 'Iniciar desafio'
          }}

          <span aria-hidden="true">→</span>
        </button>

      </article>

    </div>

    <!-- Resultado da tentativa -->
    <div
      v-if="tentativa"
      class="tentativa-feedback"
      role="status"
    >
      <strong>{{ tentativa.mensagem }}</strong>

      <p>
        Cenário: {{ tentativa.cenario }}
      </p>

      <small>
        Número da tentativa: {{ tentativa.tentativa_id }}
      </small>
    </div>

    <!-- Erro ao iniciar tentativa -->
    <div
      v-if="erroTentativa"
      class="tentativa-feedback tentativa-feedback-erro"
      role="alert"
    >
      {{ erroTentativa }}
    </div>

  </section>
</template>

