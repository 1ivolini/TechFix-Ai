-- TECHFIX AI - criação do banco, tabelas e dados iniciais
-- Compatível com MySQL / MariaDB (phpMyAdmin)
-- Não apaga dados existentes. Use no banco novo após a formatação do computador.

CREATE DATABASE IF NOT EXISTS techfixai
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE techfixai;

CREATE TABLE IF NOT EXISTS usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nome_usuario VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    Tipo ENUM('aluno', 'professor') NOT NULL DEFAULT 'aluno',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cenario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    dificuldade ENUM('facil', 'medio', 'dificil') NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_por INT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cenario_usuario FOREIGN KEY (criado_por)
        REFERENCES usuario(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS acao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cenario_id INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    resultado TEXT NOT NULL,
    relevante BOOLEAN NOT NULL DEFAULT FALSE,
    pontos INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_acao_cenario FOREIGN KEY (cenario_id)
        REFERENCES cenario(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cenario_id INT NOT NULL,
    nivel TINYINT UNSIGNED NOT NULL,
    texto TEXT NOT NULL,
    CONSTRAINT uq_dica_nivel UNIQUE (cenario_id, nivel),
    CONSTRAINT fk_dica_cenario FOREIGN KEY (cenario_id)
        REFERENCES cenario(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS diagnostico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cenario_id INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    correto BOOLEAN NOT NULL DEFAULT FALSE,
    explicacao TEXT NOT NULL,
    CONSTRAINT fk_diagnostico_cenario FOREIGN KEY (cenario_id)
        REFERENCES cenario(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tentativa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    cenario_id INT NOT NULL,
    diagnostico_id INT NULL,
    inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fim DATETIME NULL,
    pontuacao DECIMAL(5,2) NOT NULL DEFAULT 0,
    dicas_usadas INT NOT NULL DEFAULT 0,
    concluida BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_tentativa_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tentativa_cenario FOREIGN KEY (cenario_id)
        REFERENCES cenario(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tentativa_diagnostico FOREIGN KEY (diagnostico_id)
        REFERENCES diagnostico(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Compatibilidade: adiciona dicas_usadas caso a tabela já exista sem essa coluna.
SET @techfixai_add_dicas_usadas = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE tentativa ADD COLUMN dicas_usadas INT NOT NULL DEFAULT 0',
        'SELECT 1'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'tentativa'
      AND COLUMN_NAME = 'dicas_usadas'
);
PREPARE stmt_dicas_usadas FROM @techfixai_add_dicas_usadas;
EXECUTE stmt_dicas_usadas;
DEALLOCATE PREPARE stmt_dicas_usadas;

CREATE TABLE IF NOT EXISTS acao_tentativa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tentativa_id INT NOT NULL,
    acao_id INT NOT NULL,
    realizada_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pontos_obtidos INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_acao_tentativa_tentativa FOREIGN KEY (tentativa_id)
        REFERENCES tentativa(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_acao_tentativa_acao FOREIGN KEY (acao_id)
        REFERENCES acao(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dica_tentativa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tentativa_id INT NOT NULL,
    dica_id INT NOT NULL,
    solicitada_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_dica_tentativa UNIQUE (tentativa_id, dica_id),
    CONSTRAINT fk_dica_tentativa_tentativa FOREIGN KEY (tentativa_id)
        REFERENCES tentativa(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dica_tentativa_dica FOREIGN KEY (dica_id)
        REFERENCES dica(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CENÁRIOS: adiciona apenas os que ainda não existem.

INSERT INTO cenario (titulo, descricao, categoria, dificuldade, ativo)
SELECT 'Computador desliga sozinho', 'O computador desliga repentinamente durante o uso, principalmente ao executar tarefas mais exigentes. Após alguns instantes, é possível ligá-lo novamente. As conexões externas aparentam estar corretas.', 'Hardware', 'medio', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cenario WHERE titulo = 'Computador desliga sozinho');

INSERT INTO cenario (titulo, descricao, categoria, dificuldade, ativo)
SELECT 'Computador lento', 'O computador demora para iniciar, apresenta lentidão ao abrir programas e responde lentamente aos comandos do usuário. O problema pode estar relacionado ao uso excessivo de recursos, armazenamento, inicialização ou outros componentes.', 'Hardware', 'medio', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cenario WHERE titulo = 'Computador lento');

INSERT INTO cenario (titulo, descricao, categoria, dificuldade, ativo)
SELECT 'Superaquecimento do computador', 'O computador apresenta temperaturas elevadas durante o uso. As ventoinhas podem funcionar em alta velocidade, o desempenho pode diminuir e, em situações mais graves, o equipamento pode desligar para evitar danos aos componentes.', 'Hardware', 'medio', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cenario WHERE titulo = 'Superaquecimento do computador');

INSERT INTO cenario (titulo, descricao, categoria, dificuldade, ativo)
SELECT 'Computador não liga', 'Ao pressionar o botão de ligar, o computador não apresenta sinais de inicialização. As conexões externas estão corretas, mas o equipamento não responde ao comando de ligar. O aluno deverá investigar as possíveis causas antes de indicar um diagnóstico.', 'Hardware', 'medio', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cenario WHERE titulo = 'Computador não liga');

-- AÇÕES: cada ação é associada ao cenário pelo título, sem depender de IDs fixos.

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar o cabo de alimentação e a tomada', 'O cabo está conectado corretamente e a tomada funciona, mas o computador continua desligando durante o uso.', 1, 5
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar o cabo de alimentação e a tomada');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar as temperaturas e as ventoinhas', 'As temperaturas observadas estão dentro dos parâmetros esperados e as ventoinhas estão funcionando normalmente.', 1, 5
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar as temperaturas e as ventoinhas');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Testar com uma fonte compatível e funcional', 'Após o teste com uma fonte compatível e funcional, o computador deixa de desligar repentinamente durante as tarefas exigentes.', 1, 15
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Testar com uma fonte compatível e funcional');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Alterar o tema da área de trabalho', 'A alteração visual não interfere no desligamento repentino do computador.', 0, 0
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Alterar o tema da área de trabalho');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar o uso de CPU e memória no Gerenciador de Tarefas', 'Alguns processos em segundo plano estão consumindo uma quantidade significativa de memória e CPU.', 1, 15
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar o uso de CPU e memória no Gerenciador de Tarefas');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar o espaço disponível no armazenamento', 'O armazenamento possui espaço livre suficiente para o funcionamento normal do sistema.', 1, 5
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar o espaço disponível no armazenamento');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar os programas iniciados com o sistema', 'Há vários programas desnecessários iniciando junto com o sistema. Após desativar os que não são necessários, a inicialização fica mais rápida.', 1, 10
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar os programas iniciados com o sistema');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Alterar o papel de parede da área de trabalho', 'A alteração do papel de parede não resolve a causa da lentidão apresentada.', 0, 0
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Alterar o papel de parede da área de trabalho');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Inspecionar as entradas de ar e o dissipador', 'Foi observado acúmulo de poeira nas entradas de ar e no dissipador, prejudicando a circulação do ar.', 1, 15
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Inspecionar as entradas de ar e o dissipador');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar o funcionamento das ventoinhas', 'As ventoinhas estão girando e não apresentam sinais evidentes de falha mecânica.', 1, 5
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar o funcionamento das ventoinhas');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Monitorar a temperatura do processador', 'A temperatura do processador aumenta significativamente durante tarefas exigentes.', 1, 10
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Monitorar a temperatura do processador');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Alterar o papel de parede da área de trabalho', 'A alteração visual não interfere na temperatura dos componentes.', 0, 0
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Alterar o papel de parede da área de trabalho');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar o cabo de alimentação e a tomada', 'O cabo está conectado corretamente e a tomada funciona, mas o computador continua sem ligar.', 1, 5
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar o cabo de alimentação e a tomada');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Verificar a conexão do botão de ligar na placa-mãe', 'Com o computador desconectado da tomada, foi identificado que o conector PWR_SW está desconectado. Após reconectá-lo corretamente, seguindo o manual da placa-mãe e com orientação técnica, o botão volta a funcionar.', 1, 15
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Verificar a conexão do botão de ligar na placa-mãe');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Testar a fonte de alimentação com equipamento adequado', 'O teste realizado com equipamento apropriado indica que a fonte está funcionando dentro dos parâmetros esperados.', 1, 10
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Testar a fonte de alimentação com equipamento adequado');

INSERT INTO acao (cenario_id, descricao, resultado, relevante, pontos)
SELECT c.id, 'Alterar o papel de parede da área de trabalho', 'A alteração visual não interfere no funcionamento do botão de ligar nem na inicialização do computador.', 0, 0
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM acao a WHERE a.cenario_id = c.id AND a.descricao = 'Alterar o papel de parede da área de trabalho');

-- DICAS: os níveis 1 a 4 são inseridos apenas quando ainda não existem.

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 1, 'Comece observando em quais situações o computador desliga e se as conexões externas estão firmes.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 1);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 2, 'Verifique se o problema acontece durante tarefas exigentes e observe se há sinais de aquecimento excessivo.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 2);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 3, 'Confira as temperaturas e o funcionamento das ventoinhas antes de investigar outros componentes.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 3);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 4, 'Os testes apontam para a alimentação elétrica. A fonte deve ser avaliada com equipamento adequado por um professor ou técnico. Nunca abra a fonte de alimentação.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 4);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 1, 'Observe quando a lentidão acontece: durante a inicialização, ao abrir programas ou durante todo o uso.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 1);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 2, 'Use o Gerenciador de Tarefas para verificar se algum processo consome recursos excessivos de CPU ou memória.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 2);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 3, 'Verifique quais programas são iniciados automaticamente junto com o sistema operacional.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 3);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 4, 'A investigação indica excesso de processos em segundo plano. Desative apenas os programas de inicialização que você reconhece e sabe que não são necessários.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 4);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 1, 'Observe os sinais do problema, como ventoinhas muito barulhentas, perda de desempenho ou desligamentos durante o uso.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 1);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 2, 'Confira se as entradas e saídas de ar do gabinete estão desobstruídas e se existe espaço para circulação de ar.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 2);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 3, 'Inspecione visualmente a presença de poeira nas entradas de ar e no dissipador, com o computador desligado e desconectado da tomada.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 3);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 4, 'O acúmulo de poeira está prejudicando a refrigeração. A limpeza interna deve ser feita com orientação de um professor ou técnico e com o equipamento desconectado da energia.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 4);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 1, 'Comece verificando as conexões externas: confira se o cabo de alimentação está conectado corretamente e se a tomada está funcionando.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 1);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 2, 'Se as conexões externas estiverem corretas, investigue a alimentação elétrica do computador. Observe se há algum sinal de energia, como LEDs acesos ou ventoinhas girando.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 2);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 3, 'Com o computador desconectado da tomada, verifique se o conector do botão de ligar, identificado como PWR_SW, está conectado corretamente aos pinos indicados no manual da placa-mãe.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 3);

INSERT INTO dica (cenario_id, nivel, texto)
SELECT c.id, 4, 'A investigação indica que o conector PWR_SW está desconectado. Com orientação de um professor ou técnico e o computador fora da tomada, reconecte-o conforme o manual da placa-mãe e teste novamente o botão de ligar.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM dica d WHERE d.cenario_id = c.id AND d.nivel = 4);

-- DIAGNÓSTICOS: cada cenário recebe quatro alternativas, com uma correta.

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falha na fonte de alimentação', 1, 'O teste com uma fonte compatível e funcional eliminou o desligamento repentino, indicando que a fonte original é a causa mais provável neste cenário.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falha na fonte de alimentação');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Superaquecimento do processador', 0, 'As temperaturas verificadas estão dentro dos parâmetros esperados, portanto os dados deste cenário não sustentam esse diagnóstico.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Superaquecimento do processador');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Mau contato no cabo de alimentação ou na tomada', 0, 'O cabo está conectado e a tomada foi verificada. O problema continuou mesmo com essas conexões corretas.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Mau contato no cabo de alimentação ou na tomada');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falha na memória RAM', 0, 'As verificações realizadas neste cenário apontam para a fonte de alimentação, e não há evidências específicas de falha na memória RAM.'
FROM cenario c
WHERE c.titulo = 'Computador desliga sozinho'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falha na memória RAM');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Consumo excessivo de recursos por processos em segundo plano', 1, 'O Gerenciador de Tarefas mostra processos consumindo uma quantidade significativa de memória e CPU, compatível com a lentidão observada.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Consumo excessivo de recursos por processos em segundo plano');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falta de espaço livre no armazenamento', 0, 'A verificação mostrou espaço livre suficiente no armazenamento, então não há evidência de que essa seja a causa principal.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falta de espaço livre no armazenamento');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Superaquecimento do processador', 0, 'Não foram observadas evidências de temperaturas elevadas neste cenário.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Superaquecimento do processador');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falha física na memória RAM', 0, 'Os dados obtidos apontam para o consumo de recursos por processos em segundo plano, sem evidência suficiente de defeito físico na memória RAM.'
FROM cenario c
WHERE c.titulo = 'Computador lento'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falha física na memória RAM');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Acúmulo de poeira prejudicando a refrigeração', 1, 'Foi observado acúmulo de poeira nas entradas de ar e no dissipador, restringindo o fluxo de ar e contribuindo para o aumento da temperatura.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Acúmulo de poeira prejudicando a refrigeração');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falha mecânica nas ventoinhas', 0, 'As ventoinhas foram verificadas e estão funcionando normalmente, sem sinais evidentes de falha mecânica.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falha mecânica nas ventoinhas');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Pasta térmica do processador ressecada', 0, 'Embora possa causar temperaturas elevadas, não há evidência específica neste cenário que confirme pasta térmica ressecada.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Pasta térmica do processador ressecada');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falha na fonte de alimentação', 0, 'Os dados deste cenário apontam para a refrigeração comprometida pelo acúmulo de poeira, e não para uma falha da fonte.'
FROM cenario c
WHERE c.titulo = 'Superaquecimento do computador'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falha na fonte de alimentação');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Conector PWR_SW desconectado da placa-mãe', 1, 'O conector do botão de ligar estava desconectado dos pinos corretos da placa-mãe. Com o computador fora da tomada, ele deve ser reconectado conforme o manual da placa-mãe.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Conector PWR_SW desconectado da placa-mãe');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Falha na fonte de alimentação', 0, 'Uma fonte defeituosa pode impedir a inicialização, mas, neste cenário, os testes indicam que ela está funcionando corretamente.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Falha na fonte de alimentação');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Defeito no botão de ligar', 0, 'O botão não acionava a inicialização porque seu conector estava desconectado. Isso não significa que o botão esteja defeituoso.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Defeito no botão de ligar');

INSERT INTO diagnostico (cenario_id, descricao, correto, explicacao)
SELECT c.id, 'Defeito na placa-mãe', 0, 'Não há evidências suficientes para indicar defeito na placa-mãe. A causa identificada neste cenário é o conector PWR_SW desconectado.'
FROM cenario c
WHERE c.titulo = 'Computador não liga'
  AND NOT EXISTS (SELECT 1 FROM diagnostico d WHERE d.cenario_id = c.id AND d.descricao = 'Defeito na placa-mãe');

-- CONFERÊNCIA FINAL: devem aparecer quatro cenários ativos.
SELECT id, titulo, categoria, dificuldade, ativo
FROM cenario
ORDER BY id;

-- Contagem de ações, dicas e diagnósticos por cenário.
SELECT c.id, c.titulo,
       (SELECT COUNT(*) FROM acao a WHERE a.cenario_id = c.id) AS total_acoes,
       (SELECT COUNT(*) FROM dica d WHERE d.cenario_id = c.id) AS total_dicas,
       (SELECT COUNT(*) FROM diagnostico g WHERE g.cenario_id = c.id) AS total_diagnosticos
FROM cenario c
ORDER BY c.id;
