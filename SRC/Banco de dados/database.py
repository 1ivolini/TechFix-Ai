import mysql.connector
from mysql.connector import Error


def get_connection():
    try:
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",  # Ajuste conforme sua configuração
            database="techfixai"
        )

        return connection

    except Error as error:
        print(f"Erro ao conectar ao MySQL: {error}")
        return None