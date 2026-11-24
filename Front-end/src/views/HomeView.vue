
<script setup>
import { useRouter } from 'vue-router'

import AppHeader from '../components/AppHeader.vue'
import HeroSection from '../components/HeroSection.vue'
import ScenarioSection from '../components/ScenarioSection.vue'
import AppFooter from '../components/AppFooter.vue'

import { useTentativas } from '../composables/useTentativas.js'
import { useCenarios } from '../composables/useCenarios.js'

const router = useRouter()

const nomeSistema = 'TECHFIX AI'

const descricao =
  'Desenvolva suas habilidades em montagem e manutenção de computadores por meio de desafios interativos e situações do dia a dia.'

// Gerenciamento dos cenários.
const {
  cenarios,
  carregando,
  erro,
  mostrarCenarios,
  iniciarAprendizado
} = useCenarios()

// Gerenciamento das tentativas.
const {
  tentativa,
  carregando: iniciandoTentativa,
  erro: erroTentativa,
  iniciarTentativa
} = useTentativas()

// Iniciar desafio e abrir a tela de simulação.
async function iniciarDesafio(cenarioId) {
  try {
    const resultado = await iniciarTentativa(cenarioId)

    await router.push({
      name: 'simulacao',
      params: {
        tentativaId: resultado.tentativa_id,
        cenarioId: cenarioId
      }
    })

  } catch (error) {
    console.error('Erro ao iniciar desafio:', error)
  }
}
</script>

<template>
  <div class="pagina">

    <AppHeader :nome-sistema="nomeSistema" />

    <main class="conteudo">

      <HeroSection
        :descricao="descricao"
        :carregando="carregando"
        @explorar="iniciarAprendizado"
      />

      <ScenarioSection
        :cenarios="cenarios"
        :carregando="carregando"
        :erro="erro"
        :mostrar-cenarios="mostrarCenarios"
        :tentativa="tentativa"
        :iniciando-tentativa="iniciandoTentativa"
        :erro-tentativa="erroTentativa"
        @tentar-novamente="iniciarAprendizado"
        @iniciar-desafio="iniciarDesafio"
      />

    </main>

    <AppFooter />

  </div>
</template>
