
import { ref, computed } from 'vue'

import {
  cadastrarUsuario as cadastrarUsuarioApi,
  realizarLogin as realizarLoginApi
} from '../services/authService.js'

// Recuperar o token salvo na sessão.
const token = ref(sessionStorage.getItem('token') || '')

// Recuperar os dados do usuário com segurança.
const usuarioSalvo = sessionStorage.getItem('usuario')

let dadosUsuario = null

try {
  dadosUsuario = usuarioSalvo ? JSON.parse(usuarioSalvo) : null
} catch {
  sessionStorage.removeItem('usuario')
}

const usuario = ref(dadosUsuario)

// Estados da autenticação.
const carregando = ref(false)
const erro = ref('')

// Verificar se existe um token armazenado.
const autenticado = computed(() => Boolean(token.value))

// Salvar os dados da sessão.
function salvarSessao(dados) {
  token.value = dados.token
  usuario.value = dados.usuario

  sessionStorage.setItem('token', dados.token)
  sessionStorage.setItem('usuario', JSON.stringify(dados.usuario))
}

// Realizar login.
async function login(credenciais) {
  carregando.value = true
  erro.value = ''

  try {
    const resultado = await realizarLoginApi(credenciais)

    salvarSessao(resultado)

    return resultado
  } catch (error) {
    erro.value = error.message
    throw error
  } finally {
    carregando.value = false
  }
}

// Realizar cadastro.
async function cadastrar(dados) {
  carregando.value = true
  erro.value = ''

  try {
    return await cadastrarUsuarioApi(dados)
  } catch (error) {
    erro.value = error.message
    throw error
  } finally {
    carregando.value = false
  }
}

// Encerrar a sessão.
function encerrarSessao() {
  token.value = ''
  usuario.value = null

  sessionStorage.removeItem('token')
  sessionStorage.removeItem('usuario')
}

// Limpar mensagem de erro.
function limparErro() {
  erro.value = ''
}

// Disponibilizar os recursos de autenticação.
export function useAuth() {
  return {
    token,
    usuario,
    autenticado,
    carregando,
    erro,
    login,
    cadastrar,
    encerrarSessao,
    limparErro
  }
}
