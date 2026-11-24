
const API_URL = 'http://127.0.0.1:5000'

export async function listarCenarios() {
  const resposta = await fetch(`${API_URL}/cenarios`)

  if (!resposta.ok) {
    throw new Error('Falha ao consultar a API.')
  }

  return await resposta.json()
}

export async function consultarCenario(cenarioId) {
  const resposta = await fetch(`${API_URL}/cenarios/${cenarioId}`)

  const resultado = await resposta.json()

  if (!resposta.ok) {
    throw new Error(
      resultado.erro || 'Não foi possível consultar o cenário.'
    )
  }

  return resultado
}
