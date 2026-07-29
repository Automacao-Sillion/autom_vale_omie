# ============================================================
# Cria o repositorio no GitHub e faz o push deste projeto.
#
# Pre-requisitos:
#   - Git instalado          (https://git-scm.com)
#   - GitHub CLI autenticado (https://cli.github.com  ->  gh auth login)
#
# Como rodar (PowerShell, DENTRO da pasta FrontWebNFomie):
#   powershell -ExecutionPolicy Bypass -File setup_github.ps1
# ============================================================

$ErrorActionPreference = "Stop"

# >>> AJUSTE SE QUISER <<<
$RepoName   = "autom_Detalhamento_Medicao"   # nome do repositorio no GitHub
$Visibility = "private"                       # "private" ou "public"
# <<<<<<<<<<<<<<<<<<<<<<<<

Set-Location -Path $PSScriptRoot
Write-Host "Pasta do projeto: $PSScriptRoot" -ForegroundColor Cyan

# 1) Garante que segredos e lixo nao vao para o repositorio
$ignore = @(
    ".streamlit/secrets.toml",
    "__pycache__/",
    "*.pyc",
    ".venv/",
    "venv/",
    "_mod.png",
    "*.tmp"
)
if (-not (Test-Path ".gitignore")) { New-Item ".gitignore" -ItemType File | Out-Null }
$atual = Get-Content ".gitignore" -ErrorAction SilentlyContinue
foreach ($linha in $ignore) {
    if ($atual -notcontains $linha) { Add-Content ".gitignore" $linha }
}
Write-Host ".gitignore verificado (secrets.toml protegido)." -ForegroundColor Green

# 2) Inicializa o git e faz o primeiro commit
if (-not (Test-Path ".git")) { git init | Out-Null }
git add -A
git commit -m "feat: detalhamento da medicao - geracao de PDFs e envio em lote ao N8N" 2>$null
git branch -M main

# 3) Cria o repo no GitHub e faz o push
$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
    gh repo create $RepoName --$Visibility --source "." --remote origin --push
    Write-Host ""
    Write-Host "Repositorio criado e enviado: $RepoName ($Visibility)" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "GitHub CLI (gh) nao encontrado." -ForegroundColor Yellow
    Write-Host "Instale em https://cli.github.com e rode 'gh auth login'," -ForegroundColor Yellow
    Write-Host "OU crie o repo manualmente em github.com e rode:" -ForegroundColor Yellow
    Write-Host "  git remote add origin https://github.com/<seu-usuario>/$RepoName.git"
    Write-Host "  git push -u origin main"
}
