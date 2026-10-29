
from flask import Flask, jsonify, request
from mysql.connector import Error
from database import get_connection
from flask_cors import CORS

app = Flask(__name__)

CORS(
    app,
    resources={
        r"/*": {
            "origins": ["http://localhost:5173"]
        }
    }
)

@app.route("/", methods=["GET"])
def inicio():
    return jsonify({
        "mensagem": "API do TECHFIX AI funcionando!"
    })


@app.route("/cenarios", methods=["GET"])
def listar_cenarios():
    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco de dados."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        sql = """
            SELECT
                id,
                titulo,
                descricao,
                categoria,
                dificuldade,
                ativo
            FROM cenario
            WHERE ativo = TRUE
            ORDER BY id
        """

        cursor.execute(sql)
        cenarios = cursor.fetchall()

        return jsonify(cenarios), 200

    except Exception as erro:
        app.logger.exception("Erro ao consultar cenários")

        return jsonify({
            "erro": "Não foi possível consultar os cenários."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()

@app.route("/cenarios/<int:cenario_id>", methods=["GET"])
def consultar_cenario(cenario_id):
    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco de dados."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Consultar o cenário
        cursor.execute("""
            SELECT id, titulo, descricao, categoria, dificuldade
            FROM cenario
            WHERE id = %s AND ativo = TRUE
        """, (cenario_id,))

        cenario = cursor.fetchone()

        if cenario is None:
            return jsonify({
                "erro": "Cenário não encontrado."
            }), 404

        # Consultar as ações do cenário
        cursor.execute("""
            SELECT id, descricao, resultado, relevante, pontos
            FROM acao
            WHERE cenario_id = %s
            ORDER BY id
        """, (cenario_id,))

        acoes = cursor.fetchall()

        # Consultar as dicas
        cursor.execute("""
            SELECT id, nivel, texto
            FROM dica
            WHERE cenario_id = %s
            ORDER BY nivel
        """, (cenario_id,))

        dicas = cursor.fetchall()

        # Consultar os diagnósticos possíveis
        cursor.execute("""
            SELECT id, descricao, correto, explicacao
            FROM diagnostico
            WHERE cenario_id = %s
            ORDER BY id
        """, (cenario_id,))

        diagnosticos = cursor.fetchall()

        return jsonify({
            "cenario": cenario,
            "acoes": acoes,
            "dicas": dicas,
            "diagnosticos": diagnosticos
        }), 200

    except Exception:
        app.logger.exception("Erro ao consultar cenário")

        return jsonify({
            "erro": "Não foi possível consultar o cenário."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()
@app.route("/tentativas", methods=["POST"])
def iniciar_tentativa():
    dados = request.get_json(silent=True)

    if not isinstance(dados, dict):
        return jsonify({
            "erro": "Envie os dados em formato JSON."
        }), 400

    usuario_id = dados.get("usuario_id")
    cenario_id = dados.get("cenario_id")

    if (
        type(usuario_id) is not int
        or type(cenario_id) is not int
        or usuario_id <= 0
        or cenario_id <= 0
    ):
        return jsonify({
            "erro": "Informe um usuario_id e um cenario_id válidos."
        }), 400

    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco de dados."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Verificar se o usuário existe
        cursor.execute(
            "SELECT id FROM usuario WHERE id = %s",
            (usuario_id,)
        )

        if cursor.fetchone() is None:
            return jsonify({
                "erro": "Usuário não encontrado."
            }), 404

        # Verificar se o cenário existe e está ativo
        cursor.execute(
            """
            SELECT id, titulo
            FROM cenario
            WHERE id = %s AND ativo = TRUE
            """,
            (cenario_id,)
        )

        cenario = cursor.fetchone()

        if cenario is None:
            return jsonify({
                "erro": "Cenário não encontrado ou inativo."
            }), 404

        # Criar a tentativa
        cursor.execute(
            """
            INSERT INTO tentativa (usuario_id, cenario_id)
            VALUES (%s, %s)
            """,
            (usuario_id, cenario_id)
        )

        tentativa_id = cursor.lastrowid

        connection.commit()

        return jsonify({
            "mensagem": "Tentativa iniciada com sucesso.",
            "tentativa_id": tentativa_id,
            "usuario_id": usuario_id,
            "cenario": cenario["titulo"],
            "concluida": False
        }), 201

    except Error:
        connection.rollback()
        app.logger.exception("Erro ao iniciar tentativa")

        return jsonify({
            "erro": "Não foi possível iniciar a tentativa."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()
@app.route(
    "/tentativas/<int:tentativa_id>/acoes",
    methods=["POST"]
)
def registrar_acao(tentativa_id):
    dados = request.get_json(silent=True)

    if not isinstance(dados, dict):
        return jsonify({
            "erro": "Envie os dados em formato JSON."
        }), 400

    acao_id = dados.get("acao_id")

    if type(acao_id) is not int or acao_id <= 0:
        return jsonify({
            "erro": "Informe um acao_id válido."
        }), 400

    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Verifica se a tentativa existe e está aberta
        cursor.execute("""
            SELECT id, cenario_id, concluida
            FROM tentativa
            WHERE id = %s
        """, (tentativa_id,))

        tentativa = cursor.fetchone()

        if tentativa is None:
            return jsonify({
                "erro": "Tentativa não encontrada."
            }), 404

        if tentativa["concluida"]:
            return jsonify({
                "erro": "Esta tentativa já foi concluída."
            }), 409

        # Verifica se a ação pertence ao cenário da tentativa
        cursor.execute("""
            SELECT id, cenario_id, descricao, resultado,
                   relevante, pontos
            FROM acao
            WHERE id = %s
        """, (acao_id,))

        acao = cursor.fetchone()

        if acao is None:
            return jsonify({
                "erro": "Ação não encontrada."
            }), 404

        if acao["cenario_id"] != tentativa["cenario_id"]:
            return jsonify({
                "erro": "Esta ação não pertence ao cenário da tentativa."
            }), 400

        # Registra a ação realizada
        cursor.execute("""
            INSERT INTO acao_tentativa (
                tentativa_id,
                acao_id,
                pontos_obtidos
            )
            VALUES (%s, %s, %s)
        """, (
            tentativa_id,
            acao_id,
            acao["pontos"]
        ))

        registro_id = cursor.lastrowid
        connection.commit()

        return jsonify({
            "mensagem": "Ação registrada com sucesso.",
            "registro_id": registro_id,
            "tentativa_id": tentativa_id,
            "acao": acao["descricao"],
            "resultado": acao["resultado"],
            "relevante": bool(acao["relevante"]),
            "pontos_obtidos": acao["pontos"]
        }), 201

    except Exception:
        connection.rollback()
        app.logger.exception("Erro ao registrar ação")

        return jsonify({
            "erro": "Não foi possível registrar a ação."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()
@app.route(
    "/tentativas/<int:tentativa_id>/dicas",
    methods=["POST"]
)
def solicitar_dica(tentativa_id):
    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Verificar se a tentativa existe
        cursor.execute("""
            SELECT id, cenario_id, concluida
            FROM tentativa
            WHERE id = %s
        """, (tentativa_id,))

        tentativa = cursor.fetchone()

        if tentativa is None:
            return jsonify({
                "erro": "Tentativa não encontrada."
            }), 404

        if tentativa["concluida"]:
            return jsonify({
                "erro": "Esta tentativa já foi concluída."
            }), 409

        # Descobrir o próximo nível ainda não utilizado
        cursor.execute("""
            SELECT COALESCE(MAX(d.nivel), 0) + 1 AS proximo_nivel
            FROM dica_tentativa AS dt
            INNER JOIN dica AS d
                ON d.id = dt.dica_id
            WHERE dt.tentativa_id = %s
        """, (tentativa_id,))

        proximo_nivel = cursor.fetchone()["proximo_nivel"]

        # Buscar a dica do nível seguinte para este cenário
        cursor.execute("""
            SELECT id, nivel, texto
            FROM dica
            WHERE cenario_id = %s
              AND nivel = %s
        """, (
            tentativa["cenario_id"],
            proximo_nivel
        ))

        dica = cursor.fetchone()

        if dica is None:
            return jsonify({
                "erro": "Não há mais dicas disponíveis para este cenário."
            }), 404

        # Registrar a dica utilizada
        cursor.execute("""
            INSERT INTO dica_tentativa (
                tentativa_id,
                dica_id
            )
            VALUES (%s, %s)
        """, (
            tentativa_id,
            dica["id"]
        ))

        # Atualizar a quantidade de dicas usadas
        cursor.execute("""
            UPDATE tentativa
            SET dicas_usadas = (
                SELECT COUNT(*)
                FROM dica_tentativa
                WHERE tentativa_id = %s
            )
            WHERE id = %s
        """, (
            tentativa_id,
            tentativa_id
        ))

        connection.commit()

        return jsonify({
            "mensagem": "Dica disponibilizada com sucesso.",
            "tentativa_id": tentativa_id,
            "nivel": dica["nivel"],
            "texto": dica["texto"]
        }), 200

    except Exception:
        connection.rollback()
        app.logger.exception("Erro ao solicitar dica")

        return jsonify({
            "erro": "Não foi possível solicitar a dica."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()

@app.route(
    "/tentativas/<int:tentativa_id>/finalizar",
    methods=["POST"]
)
def finalizar_tentativa(tentativa_id):
    dados = request.get_json(silent=True)

    if not isinstance(dados, dict):
        return jsonify({
            "erro": "Envie os dados em formato JSON."
        }), 400

    diagnostico_id = dados.get("diagnostico_id")

    if type(diagnostico_id) is not int or diagnostico_id <= 0:
        return jsonify({
            "erro": "Informe um diagnostico_id válido."
        }), 400

    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Buscar a tentativa
        cursor.execute("""
            SELECT id, cenario_id, concluida
            FROM tentativa
            WHERE id = %s
        """, (tentativa_id,))

        tentativa = cursor.fetchone()

        if tentativa is None:
            return jsonify({
                "erro": "Tentativa não encontrada."
            }), 404

        if tentativa["concluida"]:
            return jsonify({
                "erro": "Esta tentativa já foi concluída."
            }), 409

        # Verificar se o diagnóstico pertence ao cenário
        cursor.execute("""
            SELECT id, descricao, correto
            FROM diagnostico
            WHERE id = %s
              AND cenario_id = %s
        """, (
            diagnostico_id,
            tentativa["cenario_id"]
        ))

        diagnostico = cursor.fetchone()

        if diagnostico is None:
            return jsonify({
                "erro": "Diagnóstico inválido para este cenário."
            }), 400

        # Somar os pontos das ações realizadas
        cursor.execute("""
            SELECT COALESCE(SUM(pontos_obtidos), 0) AS total
            FROM acao_tentativa
            WHERE tentativa_id = %s
        """, (tentativa_id,))

        pontuacao = cursor.fetchone()["total"]

        # Finalizar a tentativa
        cursor.execute("""
            UPDATE tentativa
            SET diagnostico_id = %s,
                fim = CURRENT_TIMESTAMP,
                pontuacao = %s,
                concluida = TRUE
            WHERE id = %s
        """, (
            diagnostico_id,
            pontuacao,
            tentativa_id
        ))

        connection.commit()

        return jsonify({
            "mensagem": "Tentativa concluída com sucesso.",
            "tentativa_id": tentativa_id,
            "diagnostico": diagnostico["descricao"],
            "diagnostico_correto": bool(diagnostico["correto"]),
            "pontuacao": float(pontuacao),
            "concluida": True
        }), 200

    except Exception:
        connection.rollback()
        app.logger.exception("Erro ao finalizar tentativa")

        return jsonify({
            "erro": "Não foi possível finalizar a tentativa."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()
@app.route("/tentativas/<int:tentativa_id>", methods=["GET"])
def consultar_tentativa(tentativa_id):
    connection = get_connection()

    if connection is None:
        return jsonify({
            "erro": "Não foi possível conectar ao banco."
        }), 500

    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Buscar os dados principais da tentativa
        cursor.execute("""
            SELECT
                t.id,
                u.nome_usuario,
                c.titulo AS cenario,
                d.descricao AS diagnostico,
                d.correto AS diagnostico_correto,
                t.inicio,
                t.fim,
                t.pontuacao,
                t.dicas_usadas,
                t.concluida
            FROM tentativa AS t
            INNER JOIN usuario AS u
                ON u.id = t.usuario_id
            INNER JOIN cenario AS c
                ON c.id = t.cenario_id
            LEFT JOIN diagnostico AS d
                ON d.id = t.diagnostico_id
            WHERE t.id = %s
        """, (tentativa_id,))

        tentativa = cursor.fetchone()

        if tentativa is None:
            return jsonify({
                "erro": "Tentativa não encontrada."
            }), 404

        # Buscar as ações realizadas
        cursor.execute("""
            SELECT
                a.descricao,
                a.relevante,
                at.pontos_obtidos,
                at.realizada_em
            FROM acao_tentativa AS at
            INNER JOIN acao AS a
                ON a.id = at.acao_id
            WHERE at.tentativa_id = %s
            ORDER BY at.realizada_em, at.id
        """, (tentativa_id,))

        acoes = cursor.fetchall()

        # Buscar as dicas utilizadas
        cursor.execute("""
            SELECT
                d.nivel,
                d.texto,
                dt.solicitada_em
            FROM dica_tentativa AS dt
            INNER JOIN dica AS d
                ON d.id = dt.dica_id
            WHERE dt.tentativa_id = %s
            ORDER BY d.nivel
        """, (tentativa_id,))

        dicas = cursor.fetchall()

        # Preparar os valores para o JSON
        tentativa["pontuacao"] = float(tentativa["pontuacao"])
        tentativa["concluida"] = bool(tentativa["concluida"])

        if tentativa["diagnostico_correto"] is not None:
            tentativa["diagnostico_correto"] = bool(
                tentativa["diagnostico_correto"]
            )

        for acao in acoes:
            acao["relevante"] = bool(acao["relevante"])

        return jsonify({
            "tentativa": tentativa,
            "acoes_realizadas": acoes,
            "dicas_utilizadas": dicas
        }), 200

    except Exception:
        connection.rollback()
        app.logger.exception("Erro ao consultar tentativa")

        return jsonify({
            "erro": "Não foi possível consultar a tentativa."
        }), 500

    finally:
        if cursor is not None:
            cursor.close()

        connection.close()
        
if __name__ == "__main__":
    app.run(debug=True)