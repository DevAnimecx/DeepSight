@echo off
REM DeepSight — Windows Quick Installer
REM Usage: curl -fsSL https://raw.githubusercontent.com/DevAnimecx/deepsight/main/install.bat | cmd
setlocal enabledelayedexpansion

set REPO=DevAnimecx/deepsight
set BRANCH=main
set DEFAULT_DIR=%USERPROFILE%\.agents\skills\deepsight
if "%~1"=="" ( set INSTALL_DIR=%DEFAULT_DIR% ) else ( set INSTALL_DIR=%~1 )

echo.
echo ========================================
echo     DeepSight v0.1.1 Installer
echo  Agentic Code Intelligence Platform
echo ========================================
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [*] Downloading DeepSight from GitHub...
powershell -Command "& { $tmp='%TEMP%\deepsight.zip'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/%REPO%/archive/refs/heads/%BRANCH%.zip' -OutFile $tmp; Expand-Archive -Path $tmp -DestinationPath '%TEMP%\deepsight-extract' -Force; Move-Item '%TEMP%\deepsight-extract\deepsight-%BRANCH%\*' '%INSTALL_DIR%\' -Force; Remove-Item $tmp; Remove-Item '%TEMP%\deepsight-extract' -Recurse -Force }"

if %ERRORLEVEL% NEQ 0 (
    echo [!] Download failed.
    where git >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        echo [*] Falling back to git clone...
        rmdir /S /Q "%INSTALL_DIR%" 2>nul
        git clone --depth 1 "https://github.com/%REPO%.git" "%INSTALL_DIR%"
    ) else (
        echo [ERR] Install failed. Install git or check your connection.
        pause
        exit /b 1
    )
)

echo.
echo [OK] DeepSight v0.1.1 installed to: %INSTALL_DIR%
echo.
echo Quick Start:
echo   /review this PR
echo   /audit security of src/
echo.
echo One-liner install:
echo   curl -fsSL https://raw.githubusercontent.com/%REPO%/%BRANCH%/install.bat ^| cmd
echo.
pause
