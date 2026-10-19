from unittest.mock import MagicMock, patch


def test_inicio_retorna_mensagem(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json() == {
        "mensagem": "API do TECHFIX AI funcionando!"
    }


def test_listar_cenarios_com_sucesso(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor
    cursor.fetchall.return_value = [
        {
            "id": 1,
            "titulo": "Computador sem vídeo",
            "descricao": "O computador liga, mas não apresenta imagem.",
            "categoria": "Hardware",
            "dificuldade": "facil",
            "ativo": 1,
        }
    ]

    with patch("app.get_connection", return_value=connection):
        response = client.get("/cenarios")

    assert response.status_code == 200

    dados = response.get_json()

    assert len(dados) == 1
    assert dados[0]["id"] == 1
    assert dados[0]["titulo"] == "Computador sem vídeo"

    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_listar_cenarios_sem_conexao(client):
    with patch("app.get_connection", return_value=None):
        response = client.get("/cenarios")

    assert response.status_code == 500
    assert response.get_json() == {
        "erro": "Não foi possível conectar ao banco de dados."
    }


def test_consultar_cenario_inexistente(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor
    cursor.fetchone.return_value = None

    with patch("app.get_connection", return_value=connection):
        response = client.get("/cenarios/9999")

    assert response.status_code == 404
    assert response.get_json() == {
        "erro": "Cenário não encontrado."
    }

    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_iniciar_tentativa_com_sucesso(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    # Simula o usuário e o cenário encontrados no banco.
    cursor.fetchone.side_effect = [
        {"id": 1},
        {
            "id": 1,
            "titulo": "Computador sem vídeo",
        },
    ]

    # Simula o ID gerado pelo banco.
    cursor.lastrowid = 25

    with patch("app.get_connection", return_value=connection):
        response = client.post(
            "/tentativas",
            json={
                "usuario_id": 1,
                "cenario_id": 1,
            },
        )

    assert response.status_code == 201

    dados = response.get_json()

    assert dados["mensagem"] == "Tentativa iniciada com sucesso."
    assert dados["tentativa_id"] == 25
    assert dados["usuario_id"] == 1
    assert dados["concluida"] is False

    connection.commit.assert_called_once()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_iniciar_tentativa_com_dados_invalidos(client):
    response = client.post(
        "/tentativas",
        json={
            "usuario_id": "abc",
            "cenario_id": 1,
        },
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "erro": "Informe um usuario_id e um cenario_id válidos."
    }

def test_registrar_acao_com_sucesso(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    # Simula uma tentativa aberta do cenário 1.
    cursor.fetchone.side_effect = [
        {
            "id": 2,
            "cenario_id": 1,
            "concluida": 0,
        },
        {
            "id": 9,
            "cenario_id": 1,
            "descricao": "Verificar o cabo de vídeo",
            "resultado": "O cabo está conectado corretamente.",
            "relevante": 1,
            "pontos": 5,
        },
    ]

    cursor.lastrowid = 40

    with patch("app.get_connection", return_value=connection):
        response = client.post(
            "/tentativas/2/acoes",
            json={"acao_id": 9},
        )

    assert response.status_code == 201

    dados = response.get_json()

    assert dados["mensagem"] == "Ação registrada com sucesso."
    assert dados["tentativa_id"] == 2
    assert dados["acao"] == "Verificar o cabo de vídeo"
    assert dados["relevante"] is True
    assert dados["pontos_obtidos"] == 5

    connection.commit.assert_called_once()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_registrar_acao_de_outro_cenario(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    # A tentativa pertence ao cenário 1,
    # mas a ação pertence ao cenário 2.
    cursor.fetchone.side_effect = [
        {
            "id": 2,
            "cenario_id": 1,
            "concluida": 0,
        },
        {
            "id": 13,
            "cenario_id": 2,
            "descricao": "Verificar a tomada",
            "resultado": "A tomada está funcionando.",
            "relevante": 1,
            "pontos": 5,
        },
    ]

    with patch("app.get_connection", return_value=connection):
        response = client.post(
            "/tentativas/2/acoes",
            json={"acao_id": 13},
        )

    assert response.status_code == 400
    assert response.get_json() == {
        "erro": "Esta ação não pertence ao cenário da tentativa."
    }

    connection.commit.assert_not_called()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()
def test_solicitar_dica_com_sucesso(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    cursor.fetchone.side_effect = [
        {
            "id": 2,
            "cenario_id": 1,
            "concluida": 0,
        },
        {
            "proximo_nivel": 1,
        },
        {
            "id": 1,
            "nivel": 1,
            "texto": "Comece verificando os elementos relacionados à imagem.",
        },
    ]

    with patch("app.get_connection", return_value=connection):
        response = client.post("/tentativas/2/dicas")

    assert response.status_code == 200

    dados = response.get_json()

    assert dados["mensagem"] == "Dica disponibilizada com sucesso."
    assert dados["tentativa_id"] == 2
    assert dados["nivel"] == 1
    assert dados["texto"] == (
        "Comece verificando os elementos relacionados à imagem."
    )

    connection.commit.assert_called_once()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()
def test_nao_permitir_dica_em_tentativa_concluida(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    cursor.fetchone.return_value = {
        "id": 2,
        "cenario_id": 1,
        "concluida": 1,
    }

    with patch("app.get_connection", return_value=connection):
        response = client.post("/tentativas/2/dicas")

    assert response.status_code == 409

    assert response.get_json() == {
        "erro": "Esta tentativa já foi concluída."
    }

    connection.commit.assert_not_called()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()

def test_finalizar_tentativa_com_sucesso(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    # Simula a tentativa aberta, o diagnóstico e a pontuação.
    cursor.fetchone.side_effect = [
        {
            "id": 2,
            "cenario_id": 1,
            "concluida": 0,
        },
        {
            "id": 8,
            "descricao": "Falha na memória RAM",
            "correto": 1,
        },
        {
            "total": 5,
        },
    ]

    with patch("app.get_connection", return_value=connection):
        response = client.post(
            "/tentativas/2/finalizar",
            json={"diagnostico_id": 8},
        )

    assert response.status_code == 200

    dados = response.get_json()

    assert dados["mensagem"] == "Tentativa concluída com sucesso."
    assert dados["tentativa_id"] == 2
    assert dados["diagnostico"] == "Falha na memória RAM"
    assert dados["diagnostico_correto"] is True
    assert dados["pontuacao"] == 5.0
    assert dados["concluida"] is True

    connection.commit.assert_called_once()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()

def test_consultar_tentativa_com_sucesso(client):
    connection = MagicMock()
    cursor = MagicMock()

    connection.cursor.return_value = cursor

    cursor.fetchone.return_value = {
        "id": 2,
        "nome_usuario": "aluno_teste",
        "cenario": "Computador sem vídeo",
        "diagnostico": "Falha na memória RAM",
        "diagnostico_correto": 1,
        "inicio": "2026-10-19 10:00:00",
        "fim": "2026-10-19 10:05:00",
        "pontuacao": 5.0,
        "dicas_usadas": 1,
        "concluida": 1,
    }

    cursor.fetchall.side_effect = [
        [
            {
                "descricao": "Verificar o cabo de vídeo",
                "relevante": 1,
                "pontos_obtidos": 5,
                "realizada_em": "2026-10-19 10:02:00",
            }
        ],
        [
            {
                "nivel": 1,
                "texto": "Verifique os elementos relacionados à imagem.",
                "solicitada_em": "2026-10-19 10:03:00",
            }
        ],
    ]

    with patch("app.get_connection", return_value=connection):
        response = client.get("/tentativas/2")

    assert response.status_code == 200

    dados = response.get_json()

    assert dados["tentativa"]["id"] == 2
    assert dados["tentativa"]["diagnostico"] == "Falha na memória RAM"
    assert dados["tentativa"]["diagnostico_correto"] is True
    assert dados["tentativa"]["pontuacao"] == 5.0
    assert dados["tentativa"]["concluida"] is True

    assert len(dados["acoes_realizadas"]) == 1
    assert dados["acoes_realizadas"][0]["pontos_obtidos"] == 5

    assert len(dados["dicas_utilizadas"]) == 1
    assert dados["dicas_utilizadas"][0]["nivel"] == 1

    cursor.close.assert_called_once()
    connection.close.assert_called_once()