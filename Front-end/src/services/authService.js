
const API_URL = import.meta.env.VITE_API_URL

// Função responsável por enviar dados ao Flask.
async function enviarDados(endpoint, dados) {
  const resposta = await fetch(`${API_URL}${endpoint}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(dados)
  })

  const resultado = await resposta.json()

  if (!resposta.ok) {
    throw new Error(
      resultado.erro || 'Não foi possível realizar a operação.'
    )
  }

  return resultado
}

// Cadastrar um novo usuário.
export async function cadastrarUsuario(usuario) {
  return await enviarDados('/usuarios', usuario)
}

// Realizar login.
export async function realizarLogin(credenciais) {
  return await enviarDados('/login', credenciais)
}
