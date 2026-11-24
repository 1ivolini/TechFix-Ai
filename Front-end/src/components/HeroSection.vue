
<script setup>
defineProps({
  descricao: {
    type: String,
    default: ''
  },
  carregando: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['explorar'])
</script>

<template>
  <section class="hero">
    <div class="hero-texto">
      <span class="etiqueta">
        <span aria-hidden="true">✦</span>
        APRENDA FAZENDO
      </span>

      <h1>
        Diagnostique.
        <span>Aprenda.</span>
        Evolua.
      </h1>

      <p>{{ descricao }}</p>

      <button
        type="button"
        class="botao-principal"
        :disabled="carregando"
        @click="emit('explorar')"
      >
        {{ carregando ? 'Carregando cenários...' : 'Explorar cenários' }}
        <span aria-hidden="true">→</span>
      </button>

      <div class="texto-apoio">
        <span aria-hidden="true">✓</span>
        Aprendizado prático para estudantes e professores
      </div>
    </div>

    <div class="hero-visual" aria-hidden="true">
      <div class="circulo circulo-grande"></div>
      <div class="circulo circulo-pequeno"></div>

      <div class="monitor">
        <div class="monitor-topo">
          <span></span>
          <span></span>
          <span></span>
        </div>

        <div class="monitor-conteudo">
          <div class="monitor-icone">PC</div>

          <div class="linha linha-longa"></div>
          <div class="linha linha-media"></div>

          <div class="monitor-blocos">
            <div></div>
            <div></div>
            <div></div>
          </div>
        </div>

        <div class="monitor-base"></div>
      </div>

      <div class="flutuante">
        <span class="flutuante-icone">✓</span>

        <div>
          <strong>Mão na massa!</strong>
          <small>Aprenda na prática</small>
        </div>
      </div>
    </div>
  </section>
</template>
