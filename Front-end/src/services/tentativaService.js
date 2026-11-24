
const API_URL = 'http://127.0.0.1:5000'

// Iniciar uma tentativa utilizando autenticação JWT.
export async function iniciarTentativa(cenarioId, token) {

  if (!token) {
    throw new Error('Você precisa estar autenticado para iniciar uma tentativa.')
  }

  const resposta = await fetch(`${API_URL}/tentativas`, {
    method: 'POST',

    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },

    body: JSON.stringify({
      cenario_id: cenarioId
    })
  })

  const resultado = await resposta.json()

  if (!resposta.ok) {
    throw new Error(
      resultado.erro || 'Não foi possível iniciar a tentativa.'
    )
  }

  return resultado
}

export async function registrarAcao(tentativaId, acaoId, token) {
  if (!token) {
          throw new Error(
            'Você precisa estar autenticado para registrar uma ação.'
          )
        }
  const resposta = await fetch(
    `${API_URL}/tentativas/${tentativaId}/acoes`,
    {
      
      method: 'POST',

      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },

      body: JSON.stringify({
        acao_id: acaoId
      })
    }
  )

  const resultado = await resposta.json()

  if (!resposta.ok) {
    throw new Error(
      resultado.erro || 'Não foi possível registrar a ação.'
    )
  }

  return resultado
}
