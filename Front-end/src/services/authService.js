
const API_URL = 'http://127.0.0.1:5000'

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
