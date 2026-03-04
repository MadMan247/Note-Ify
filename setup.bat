#TODO
@echo off
setlocal enabledelayedexpansion

echo =====================================
echo   Note-Ify Windows Setup (Step Mode)
echo =====================================

:: Ask for Discord Auth ID
echo Step 1: Enter Discord Auth ID
set /p DISCORD_AUTH=Enter your Discord Auth ID: 

if "%DISCORD_AUTH%"=="" (
    echo Discord Auth ID cannot be empty.
    pause
    exit /b 1
)

echo DISCORD_AUTH=%DISCORD_AUTH% > .env
echo Saved to discord-auth.env
pause


:: Check for Git
echo Step 2: Checking for Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed. Install Git for Windows first.
    pause
    exit /b 1
)
echo Git found.
pause


:: Clone Note-Ify (skip if already exists)
echo Step 3: Cloning Note-Ify
pause
if not exist "Note-Ify" (
    git clone https://github.com/Spar3Chang3/Note-Ify.git
    if %errorlevel% neq 0 (
        echo Git clone failed.
        pause
        exit /b 1
    )
) else (
    echo Note-Ify folder already exists. Skipping clone.
)
pause


:: Check for Bun
echo Step 4: Checking for Bun
where bun >nul 2>nul
if %errorlevel% neq 0 (
    echo Bun not found. Installing Bun...
    pause
    powershell -Command "irm https://bun.sh/install.ps1 | iex"
    set "PATH=%USERPROFILE%\.bun\bin;%PATH%"
) else (
    echo Bun already installed.
)
pause


:: Install dependencies and build Note-Ify
echo Step 5: Installing dependencies and building Note-Ify
pause
cd Note-Ify

if not exist "package.json" (
    echo package.json not found. Cannot install dependencies.
    pause
    exit /b 1
)

echo Running bun install...
bun install
if %errorlevel% neq 0 (
    echo bun install failed.
    pause
    exit /b 1
)

echo Building Note-Ify...
bun build index.js --compile --outfile noteify.exe
if %errorlevel% neq 0 (
    echo Bun build failed.
    pause
    exit /b 1
)

cd ..
pause


:: Install Ollama
echo Step 6: Installing Ollama
pause
powershell -Command "irm https://ollama.com/install.ps1 | iex"
pause


:: Clone whisper.cpp
echo Step 7: Cloning whisper.cpp
pause
if not exist "whisper.cpp" (
    git clone https://github.com/ggml-org/whisper.cpp.git
    if %errorlevel% neq 0 (
        echo whisper.cpp clone failed.
        pause
        exit /b 1
    )
) else (
    echo whisper.cpp folder already exists. Skipping clone.
)
pause


:: Download model
echo Step 8: Downloading ggml-base.bin
pause
if not exist "whisper.cpp\ggml-base.bin" (
    curl -L -o whisper.cpp\ggml-base.bin ^
    https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin?download=true
    if %errorlevel% neq 0 (
        echo Model download failed.
        pause
        exit /b 1
    )
) else (
    echo Model already exists. Skipping download.
)
pause


:: Build whisper.cpp
echo Step 9: Building whisper.cpp
pause
cd whisper.cpp

cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
if %errorlevel% neq 0 (
    echo CMake generation failed.
    pause
    exit /b 1
)

pause

cmake --build build --config Release
if %errorlevel% neq 0 (
    echo Build failed.
    pause
    exit /b 1
)

cd ..
pause


echo =====================================
echo            Setup Complete
echo =====================================
pause
