CREATE DATABASE Techfixai;



CREATE TABLE usuario(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nome_usuario VARCHAR(50) NOT NULL UNIQUE, 
    email VARCHAR(150) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    Tipo ENUM('aluno', 'professor') NOT NULL DEFAULT 'aluno',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cenario(
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
);

CREATE TABLE acao(
    id INT AUTO_INCREMENT PRIMARY KEY,
    cenario_id INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    resultado TEXT NOT NULL, 
    relevante BOOLEAN NOT NULL DEFAULT FALSE,
    pontos INT NOT NULL DEFAULT 0,

    CONSTRAINT fk_acao_cenario
        FOREIGN KEY (cenario_id)
        REFERENCES cenario(id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE

);

CREATE TABLE dica (

        id INT AUTO_INCREMENT PRIMARY KEY,
        cenario_id INT NOT NULL,
        nivel TINYINT UNSIGNED NOT NULL,
        texto TEXT NOT NULL,


        CONSTRAINT uq_dica_nivel
            UNIQUE (cenario_id, nivel),

        CONSTRAINT uq_dica_nivel
            FOREIGN KEY (cenario_id)
            REFERENCES cenario(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE

);

CREATE TABLE diagnostico(
    id INT AUTO_INCREMENT PRIMARY KEY,
    cenario_id INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    correto BOOLEAN NOT NULL DEFAULT FALSE,
    explicacao TEXT NOT NULL,

    CONSTRAINT fk_diagnostico_cenario
        FOREIGN KEY (cenario_id)
        REFERENCES cenario(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE tentativa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    cenario_id INT NOT NULL,
    diagnostico_id INT NULL,
    inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fim DATETIME NULL,
    pontuacao DECIMAL(5,2) NOT NULL DEFAULT 0,
    concluida BOOLEAN NOT NULL DEFAULT FALSE,



    CONSTRAINT fk_tentativa_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_tentativa_cenario
        FOREIGN KEY (cenario_id)
        REFERENCES cenario(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_tentativa_diagnostico
        FOREIGN KEY(diagnostico_id)
        REFERENCES diagnostico(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE

);

CREATE TABLE acao_tentativa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tentativa_id INT NOT NULL,
    acao_id int NOT NULL,
    realizada_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pontos_obtidos INT NOT NULL DEFAULT 0,


    CONSTRAINT fk_acao_tentativa_tentativa
        FOREIGN KEY (tentativa_id)
        REFERENCES tentativa(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_acao_tentativa_acao
        FOREIGN KEY (acao_id)
        REFERENCES acao(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

);



CREATE TABLE dica_tentativa(
    id INT AUTO_INCREMENT PRIMARY KEY,
    tentativa_id INT NOT NULL,
    dica_id INT NOT NULL,
    solicitada_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    
    CONSTRAINT uq_dica_tentativa
        UNIQUE (tentativa_id,dica_id),

    CONSTRAINT fk_dica_tentativa_tentativa
        FOREIGN KEY (tentativa_id)
        REFERENCES tentativa(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_dica_tentativa_dica
        FOREIGN KEY (dica_id)
        REFERENCES dica(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE


);