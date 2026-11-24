
import { ref } from 'vue'
import { listarCenarios } from '../services/cenarioService.js'

export function useCenarios() {
  const cenarios = ref([])
  const carregando = ref(false)
  const erro = ref('')
  const mostrarCenarios = ref(false)

  async function iniciarAprendizado() {
    carregando.value = true
    erro.value = ''
    mostrarCenarios.value = true

    try {
      cenarios.value = await listarCenarios()
    } catch (error) {
      console.error('Erro ao buscar cenários:', error)

      erro.value =
        'Não foi possível carregar os cenários. Verifique se a API está funcionando.'
    } finally {
      carregando.value = false
    }
  }

  return {
    cenarios,
    carregando,
    erro,
    mostrarCenarios,
    iniciarAprendizado
  }
}
