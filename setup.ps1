$ErrorActionPreference = "Stop"

# Executa a partir da pasta onde este script está salvo.
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

Write-Host "== Configurando o ambiente Python do TECHFIX AI ==" -ForegroundColor Cyan

# Confere se o Python está instalado.
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "Python encontrado: $pythonVersion"
} catch {
    Write-Error "Python não foi encontrado. Instale o Python 3 e marque a opção para adicioná-lo ao PATH."
    exit 1
}

$VenvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"

# Cria o ambiente virtual apenas se ele ainda não existir.
if (-not (Test-Path $VenvPython)) {
    Write-Host "Criando ambiente virtual .venv..." -ForegroundColor Yellow
    & python -m venv (Join-Path $ProjectRoot ".venv")
    if ($LASTEXITCODE -ne 0) {
        throw "Não foi possível criar o ambiente virtual. Confira a instalação do Python."
    }
} else {
    Write-Host "Ambiente virtual .venv já existe."
}

Write-Host "Atualizando pip..." -ForegroundColor Yellow
& $VenvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao atualizar pip. Confira sua conexão com a internet."
}

Write-Host "Instalando dependências de requirements.txt..." -ForegroundColor Yellow
& $VenvPython -m pip install -r (Join-Path $ProjectRoot "requirements.txt")
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao instalar as dependências. Confira a mensagem acima e a conexão com a internet."
}

Write-Host "`nConfiguração concluída!" -ForegroundColor Green
Write-Host "Para ativar o ambiente nesta janela do PowerShell, execute:"
Write-Host ".\.venv\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host "Depois, para iniciar o Flask, entre na pasta do backend e execute python app.py."
