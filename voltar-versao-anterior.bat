@echo off
title DXCORE - voltar para a versao anterior
set D=%LOCALAPPDATA%\DXCORE
if not exist "%D%\DXCORE.anterior.html" (
  echo Nao tem versao anterior guardada neste computador.
  pause
  exit /b
)
copy /y "%D%\DXCORE.anterior.html" "%D%\DXCORE.html" >nul
echo Voltou para a versao anterior. Ela fica ate sair uma versao nova.
pause
