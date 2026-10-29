
<script setup>
import { ref } from 'vue'

const nomeSistema = 'TECHFIX AI'
const descricao =
  'Desenvolva suas habilidades em montagem e manutenção de computadores por meio de desafios interativos e situações do dia a dia.'

const cenarios = ref([])
const carregando = ref(false)
const erro = ref('')
const mostrarCenarios = ref(false)

async function iniciarAprendizado() {
  carregando.value = true
  erro.value = ''
  mostrarCenarios.value = true

  try {
    const resposta = await fetch('http://127.0.0.1:5000/cenarios')

    if (!resposta.ok) {
      throw new Error('Falha ao consultar a API.')
    }

    cenarios.value = await resposta.json()
  } catch (error) {
    console.error('Erro ao buscar cenários:', error)
    erro.value =
      'Não foi possível carregar os cenários. Verifique se a API está funcionando.'
  } finally {
    carregando.value = false
  }
}

function formatarDificuldade(dificuldade) {
  const niveis = {
    facil: 'Fácil',
    medio: 'Médio',
    dificil: 'Difícil',
  }

  return niveis[dificuldade?.toLowerCase()] || dificuldade || 'Não informada'
}
</script>

<template>
  <div class="pagina">
    <header class="cabecalho">
      <div class="cabecalho-conteudo">
        <a class="marca" href="#" aria-label="TECHFIX AI - início">
          <span class="marca-icone">TF</span>

          <span class="marca-texto">
            <strong>{{ nomeSistema }}</strong>
            <small>Aprendizado em informática</small>
          </span>
        </a>

        <span class="status-plataforma">
          <span class="status-ponto"></span>
          Ambiente de aprendizagem
        </span>
      </div>
    </header>

    <main class="conteudo">
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
            @click="iniciarAprendizado"
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

        <div v-if="!mostrarCenarios" class="estado-inicial">
          <div class="estado-icone">⌕</div>
          <strong>Seu próximo desafio começa aqui</strong>
          <p>
            Clique em “Explorar cenários” para visualizar os desafios disponíveis.
          </p>
        </div>

        <div v-else-if="carregando" class="estado-inicial">
          <div class="carregando-icone"></div>
          <strong>Preparando seus desafios...</strong>
          <p>Buscando os cenários disponíveis.</p>
        </div>

        <div v-else-if="erro" class="estado-inicial estado-erro">
          <div class="estado-icone">!</div>
          <strong>Não foi possível carregar os cenários</strong>
          <p>{{ erro }}</p>

          <button
            type="button"
            class="botao-secundario"
            @click="iniciarAprendizado"
          >
            Tentar novamente
          </button>
        </div>

        <div v-else-if="cenarios.length === 0" class="estado-inicial">
          <div class="estado-icone">⌕</div>
          <strong>Nenhum cenário disponível</strong>
          <p>Novos desafios poderão aparecer aqui quando forem cadastrados.</p>
        </div>

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
          </article>
        </div>
      </section>
    </main>

    <footer class="rodape">
      <div class="rodape-conteudo">
        <a class="rodape-marca" href="#">
          TECHFIX <span>AI</span>
        </a>

        <p>Aprender, investigar e evoluir na informática.</p>

        <span class="rodape-direitos">
          Educação em informática
        </span>
      </div>
    </footer>
  </div>
</template>

<style>
* {
  box-sizing: border-box;
}

html {
  width: 100%;
  min-height: 100%;
  scroll-behavior: smooth;
}

body {
  width: 100%;
  min-width: 320px;
  min-height: 100vh;
  margin: 0;
  font-family: Arial, Helvetica, sans-serif;
  color: #172554;
  background: #f5f7fc;
}

button,
a {
  font: inherit;
}

button {
  -webkit-tap-highlight-color: transparent;
}

button:focus-visible,
a:focus-visible {
  outline: 3px solid #93c5fd;
  outline-offset: 4px;
}

.pagina {
  display: flex;
  flex-direction: column;
  width: 100%;
  min-height: 100vh;
}

/* Cabeçalho */

.cabecalho {
  width: 100%;
  background: #111d40;
  color: #ffffff;
}

.cabecalho-conteudo {
  width: min(1180px, 100%);
  min-height: 86px;
  margin: 0 auto;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
}

.marca {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  color: inherit;
  text-decoration: none;
}

.marca-icone {
  width: 44px;
  height: 44px;
  display: grid;
  place-items: center;
  border-radius: 12px;
  background: #2563eb;
  color: white;
  font-size: 15px;
  font-weight: 800;
}

.marca-texto {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.marca-texto strong {
  font-size: 19px;
  letter-spacing: 0.4px;
}

.marca-texto small {
  color: #bfcee9;
  font-size: 12px;
}

.status-plataforma {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 10px 14px;
  border: 1px solid rgb(255 255 255 / 12%);
  border-radius: 30px;
  color: #dbeafe;
  font-size: 12px;
}

.status-ponto,
.nivel-ponto {
  width: 8px;
  height: 8px;
  flex-shrink: 0;
  border-radius: 50%;
  background: #4ade80;
}

/* Conteúdo principal */

.conteudo {
  flex: 1;
  width: 100%;
  max-width: 1180px;
  margin: 0 auto;
  padding: 42px 24px 72px;
}

/* Apresentação */

.hero {
  position: relative;
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  align-items: center;
  gap: 36px;
  min-height: 350px;
  padding: 46px 54px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
  border-radius: 24px;
  background: linear-gradient(120deg, #ffffff 0%, #f0f5ff 100%);
  box-shadow: 0 12px 36px rgb(15 23 42 / 5%);
}

.hero-texto {
  position: relative;
  z-index: 2;
}

.etiqueta {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 20px;
  color: #2563eb;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 1.4px;
}

.hero h1 {
  max-width: 520px;
  margin: 0;
  color: #14213f;
  font-size: clamp(34px, 4vw, 48px);
  font-weight: 800;
  line-height: 1.14;
  letter-spacing: -1.7px;
}

.hero h1 span {
  color: #2563eb;
}

.hero-texto > p {
  max-width: 490px;
  margin: 20px 0 26px;
  color: #64748b;
  font-size: 15px;
  line-height: 1.8;
}

.botao-principal {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  min-height: 48px;
  padding: 13px 22px;
  border: 0;
  border-radius: 9px;
  background: #2563eb;
  color: white;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 6px 14px rgb(37 99 235 / 18%);
  transition:
    background-color 0.2s,
    transform 0.2s,
    box-shadow 0.2s;
}

.botao-principal:hover:not(:disabled) {
  transform: translateY(-2px);
  background: #1d4ed8;
  box-shadow: 0 9px 18px rgb(37 99 235 / 24%);
}

.botao-principal:disabled {
  opacity: 0.65;
  cursor: wait;
}

.texto-apoio {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 20px;
  color: #64748b;
  font-size: 12px;
}

.texto-apoio span {
  color: #16a34a;
  font-size: 16px;
  font-weight: 800;
}

/* Ilustração construída com CSS */

.hero-visual {
  position: relative;
  display: grid;
  min-height: 250px;
  place-items: center;
}

.circulo {
  position: absolute;
  border-radius: 50%;
}

.circulo-grande {
  width: 250px;
  height: 250px;
  background: #dce8ff;
}

.circulo-pequeno {
  width: 190px;
  height: 190px;
  border: 1px solid #b8ceff;
}

.monitor {
  position: relative;
  z-index: 1;
  width: min(245px, 80%);
  padding: 9px;
  border: 2px solid #314675;
  border-radius: 12px;
  background: #172554;
  box-shadow: 0 18px 28px rgb(23 37 84 / 18%);
  transform: rotate(-3deg);
}

.monitor-topo {
  display: flex;
  gap: 5px;
  padding: 3px 2px 9px;
}

.monitor-topo span {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #93a9d4;
}

.monitor-conteudo {
  min-height: 125px;
  padding: 17px;
  border-radius: 5px;
  background: #ffffff;
}

.monitor-icone {
  display: grid;
  width: 43px;
  height: 35px;
  margin-bottom: 13px;
  place-items: center;
  border-radius: 6px;
  background: #dbeafe;
  color: #2563eb;
  font-size: 14px;
  font-weight: 800;
}

.linha {
  height: 6px;
  margin-bottom: 7px;
  border-radius: 5px;
  background: #dce4f1;
}

.linha-longa {
  width: 100%;
}

.linha-media {
  width: 67%;
}

.monitor-blocos {
  display: flex;
  gap: 7px;
  margin-top: 15px;
}

.monitor-blocos div {
  flex: 1;
  height: 21px;
  border-radius: 4px;
  background: #dbeafe;
}

.monitor-blocos div:nth-child(2) {
  background: #bfdbfe;
}

.monitor-blocos div:nth-child(3) {
  background: #93c5fd;
}

.monitor-base {
  width: 65px;
  height: 9px;
  margin: 0 auto;
  border-radius: 0 0 5px 5px;
  background: #314675;
}

.flutuante {
  position: absolute;
  right: -4px;
  bottom: 20px;
  z-index: 2;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 13px 16px;
  border: 1px solid #e6ebf4;
  border-radius: 12px;
  background: white;
  box-shadow: 0 8px 24px rgb(15 23 42 / 10%);
  transform: rotate(2deg);
}

.flutuante-icone {
  display: grid;
  width: 32px;
  height: 32px;
  place-items: center;
  border-radius: 9px;
  background: #dcfce7;
  color: #15803d;
  font-weight: 800;
}

.flutuante div {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.flutuante strong {
  color: #172554;
  font-size: 11px;
}

.flutuante small {
  color: #64748b;
  font-size: 10px;
}

/* Cenários */

.secao-cenarios {
  width: 100%;
  margin-top: 54px;
  scroll-margin-top: 24px;
}

.secao-cabecalho {
  display: flex;
  justify-content: space-between;
  align-items: end;
  gap: 20px;
  margin-bottom: 24px;
}

.sobretitulo {
  display: inline-block;
  margin-bottom: 9px;
  color: #2563eb;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 1.5px;
}

.secao-cabecalho h2 {
  margin: 0;
  color: #172554;
  font-size: 28px;
  letter-spacing: -0.7px;
}

.secao-cabecalho p {
  margin: 10px 0 0;
  color: #64748b;
  font-size: 14px;
  line-height: 1.6;
}

.contador {
  flex-shrink: 0;
  padding: 9px 13px;
  border: 1px solid #dbeafe;
  border-radius: 9px;
  background: #eff6ff;
  color: #1d4ed8;
  font-size: 12px;
  font-weight: 700;
}

.lista-cenarios {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
}

.card-cenario {
  display: flex;
  flex-direction: column;
  min-width: 0;
  min-height: 245px;
  padding: 25px;
  border: 1px solid #e5eaf2;
  border-radius: 15px;
  background: #ffffff;
  box-shadow: 0 4px 15px rgb(15 23 42 / 3%);
  transition:
    border-color 0.2s,
    box-shadow 0.2s,
    transform 0.2s;
}

.card-cenario:hover {
  transform: translateY(-4px);
  border-color: #b9d0ff;
  box-shadow: 0 12px 26px rgb(15 23 42 / 7%);
}

.card-topo {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 19px;
}

.categoria {
  display: inline-flex;
  align-items: center;
  padding: 6px 10px;
  border-radius: 6px;
  background: #eff6ff;
  color: #1d4ed8;
  font-size: 11px;
  font-weight: 700;
}

.numero-cenario {
  color: #cbd5e1;
  font-size: 23px;
  font-weight: 800;
  letter-spacing: -1px;
}

.card-cenario h3 {
  margin: 0 0 12px;
  color: #1e293b;
  font-size: 19px;
  line-height: 1.4;
}

.card-descricao {
  flex: 1;
  margin: 0 0 22px;
  color: #64748b;
  font-size: 13px;
  line-height: 1.8;
}

.card-rodape {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid #eef2f7;
}

.nivel {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  color: #475569;
  font-size: 12px;
  font-weight: 700;
}

.nivel-ponto {
  background: #f59e0b;
}

.tipo-desafio {
  color: #94a3b8;
  font-size: 11px;
}

/* Estados da busca */

.estado-inicial {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 46px 24px;
  border: 1px dashed #cbd5e1;
  border-radius: 15px;
  background: rgb(255 255 255 / 65%);
  text-align: center;
}

.estado-icone {
  display: grid;
  width: 46px;
  height: 46px;
  margin-bottom: 15px;
  place-items: center;
  border-radius: 12px;
  background: #dbeafe;
  color: #2563eb;
  font-size: 24px;
  font-weight: 700;
}

.estado-inicial strong {
  color: #172554;
  font-size: 15px;
}

.estado-inicial p {
  max-width: 440px;
  margin: 10px 0 0;
  color: #64748b;
  font-size: 13px;
  line-height: 1.7;
}

.estado-erro .estado-icone {
  background: #fee2e2;
  color: #b91c1c;
}

.carregando-icone {
  width: 32px;
  height: 32px;
  margin-bottom: 18px;
  border: 3px solid #dbeafe;
  border-top-color: #2563eb;
  border-radius: 50%;
  animation: girar 0.8s linear infinite;
}

.botao-secundario {
  margin-top: 20px;
  padding: 11px 16px;
  border: 1px solid #bfdbfe;
  border-radius: 8px;
  background: white;
  color: #1d4ed8;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}

.botao-secundario:hover {
  background: #eff6ff;
}

@keyframes girar {
  to {
    transform: rotate(360deg);
  }
}

/* Rodapé */

.rodape {
  width: 100%;
  border-top: 1px solid #e2e8f0;
  background: #ffffff;
}

.rodape-conteudo {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  width: min(1180px, 100%);
  min-height: 78px;
  margin: 0 auto;
  padding: 20px 24px;
}

.rodape-marca {
  color: #172554;
  font-size: 14px;
  font-weight: 800;
  letter-spacing: 0.3px;
  text-decoration: none;
}

.rodape-marca span {
  color: #2563eb;
}

.rodape-conteudo p {
  margin: 0;
  color: #64748b;
  font-size: 12px;
}

.rodape-direitos {
  color: #94a3b8;
  font-size: 11px;
}

/* Adaptação para telas menores */

@media (max-width: 850px) {
  .conteudo {
    padding-top: 28px;
  }

  .hero {
    grid-template-columns: 1fr;
    gap: 10px;
    padding: 38px 30px;
  }

  .hero-visual {
    min-height: 235px;
  }

  .flutuante {
    right: 5%;
  }
}

@media (max-width: 600px) {
  .cabecalho-conteudo {
    padding: 15px 18px;
  }

  .status-plataforma {
    padding: 8px;
    font-size: 0;
  }

  .status-ponto {
    width: 9px;
    height: 9px;
  }

  .conteudo {
    padding: 20px 16px 42px;
  }

  .hero {
    padding: 30px 23px;
    border-radius: 17px;
  }

  .hero h1 {
    font-size: 36px;
  }

  .hero-texto > p {
    font-size: 14px;
  }

  .hero-visual {
    min-height: 220px;
  }

  .circulo-grande {
    width: 210px;
    height: 210px;
  }

  .circulo-pequeno {
    width: 160px;
    height: 160px;
  }

  .monitor {
    width: 215px;
  }

  .flutuante {
    right: 0;
    bottom: 10px;
  }

  .secao-cenarios {
    margin-top: 38px;
  }

  .secao-cabecalho h2 {
    font-size: 24px;
  }

  .secao-cabecalho p {
    font-size: 13px;
  }

  .lista-cenarios {
    grid-template-columns: 1fr;
    gap: 15px;
  }

  .card-cenario {
    padding: 21px;
  }

  .rodape-conteudo {
    justify-content: center;
    text-align: center;
  }

  .rodape-conteudo p {
    width: 100%;
    order: 3;
  }
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    scroll-behavior: auto !important;
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
</style>
