@echo off
REM DeepSight — Windows Launcher
REM Installs to: Claude Desktop (%APPDATA%\Claude\agents\skills\deepsight)
REM              Claude Code  (%USERPROFILE%\.agents\skills\deepsight)
REM One-liner (CMD):  powershell -c "iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/main/install.ps1 | iex"
REM One-liner (PS):   iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/main/install.ps1 | iex"
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
pause

