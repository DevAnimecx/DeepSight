@echo off
REM DeepSight — Windows Launcher
REM Calls install.ps1 (the real installer)
REM Usage: powershell -c "iwr -useb https://raw.githubusercontent.com/DevAnimecx/deepsight/main/install.ps1 | iex"
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
pause

