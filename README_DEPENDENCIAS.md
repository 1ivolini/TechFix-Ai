# Configuração de dependências — TECHFIX AI

## Arquivos
- `requirements.txt`: lista as dependências Python do backend e dos testes.
- `setup.ps1`: cria o ambiente virtual `.venv` e instala/atualiza as dependências listadas.

## Depois de clonar o repositório no Windows
1. Coloque estes arquivos na pasta principal do repositório (a mesma pasta onde fica a pasta `Back-end` e a pasta `tests`).
2. Abra o PowerShell nessa pasta.
3. Execute:

   ```powershell
   .\setup.ps1
   ```

4. Ative o ambiente virtual nessa mesma janela:

   ```powershell
   .\.venv\Scripts\Activate.ps1
   ```

5. Para testar:

   ```powershell
   python -m pytest -v
   ```

6. Para iniciar o backend:

   ```powershell
   cd "Back-end\Banco de dados"
   python app.py
   ```

Se o PowerShell bloquear a execução do script, rode-o nesta sessão com:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

O comando acima instala as dependências no ambiente virtual, mas a ativação deve ser feita depois no terminal atual usando o comando do passo 4.

## Importante
- O Python precisa estar instalado no computador e disponível no `PATH`.
- É necessária conexão com a internet durante a instalação dos pacotes.
- O Git clone não executa a instalação automaticamente; execute `setup.ps1` uma vez depois de clonar (e novamente quando alterar `requirements.txt`).
- O MySQL Server e a criação/importação do banco `techfixai` são etapas separadas; não são instalados pelo `pip`.
- Inclua `.venv/` no `.gitignore` para não enviar o ambiente virtual ao GitHub.
