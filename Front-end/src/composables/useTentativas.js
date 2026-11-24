
import { ref } from 'vue'
import { useAuth } from './useAuth.js'

import {
  iniciarTentativa as iniciarTentativaApi,
  registrarAcao as registrarAcaoApi
} from '../services/tentativaService.js'

export function useTentativas() {
  const { token, autenticado } = useAuth()

  const tentativa = ref(null)
  const acoesRegistradas = ref([])

  const carregando = ref(false)
  const registrandoAcao = ref(false)

  const erro = ref('')

  // Verificar autenticação.
  function verificarAutenticacao() {
    if (!autenticado.value || !token.value) {
      throw new Error(
        'Você precisa estar autenticado para realizar esta operação.'
      )
    }
  }

  // Iniciar uma tentativa.
  async function iniciarTentativa(cenarioId) {
    erro.value = ''
    tentativa.value = null
    acoesRegistradas.value = []

    verificarAutenticacao()

    carregando.value = true

    try {
      const resultado = await iniciarTentativaApi(
        cenarioId,
        token.value
      )

      tentativa.value = resultado

      return resultado

    } catch (error) {
      erro.value = error.message
      throw error

    } finally {
      carregando.value = false
    }
  }

  // Registrar uma ação na tentativa.
  async function registrarAcao(tentativaId, acaoId) {
    erro.value = ''

    verificarAutenticacao()

    registrandoAcao.value = true

    try {
      const resultado = await registrarAcaoApi(
        tentativaId,
        acaoId,
        token.value
      )

      acoesRegistradas.value.push(resultado)

      return resultado

    } catch (error) {
      erro.value = error.message
      throw error

    } finally {
      registrandoAcao.value = false
    }
  }

  return {
    tentativa,
    acoesRegistradas,
    carregando,
    registrandoAcao,
    erro,
    iniciarTentativa,
    registrarAcao
  }
}
