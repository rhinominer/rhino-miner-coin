@echo off
REM Build Linux GUI Wallet using Docker
REM This will create binaries in build-output\linux-gui\

echo ======================================
echo Rhino Miner Coin - Linux GUI Builder
echo ======================================
echo.
echo This will build the GUI wallet for Linux (rhino-qt)
echo.
echo Building... (this may take 15-30 minutes)
echo.

REM Change to rhino-miner-coin directory
cd /d "%~dp0"

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Build using Docker
docker build -f docker\build-linux-gui.Dockerfile -t rhino-miner-coin-gui-builder .

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

REM Create output directory
if not exist "build-output\linux-gui" mkdir build-output\linux-gui

REM Run container to extract binaries
docker run --rm -v "%cd%\build-output:/out" rhino-miner-coin-gui-builder

echo.
echo ======================================
echo BUILD COMPLETE!
echo ======================================
echo.
echo Binaries are in: build-output\linux-gui\
echo.
dir /b build-output\linux-gui\
echo.
echo To run the GUI wallet on Linux:
echo   ./build-output/linux-gui/rhino-qt
echo.
echo To run the daemon:
echo   ./build-output/linux-gui/rhinod
echo.
pause
