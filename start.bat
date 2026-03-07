@echo off
cd /d "%~dp0"

:: -------------------------
:: Create start_noteify.bat
:: -------------------------
if not exist start_noteify.bat (
(
echo @echo off
echo tasklist ^| find /i "noteify.exe" ^>nul
echo if %%errorlevel%%==0 (
echo     echo Noteify already running.
echo     pause
echo     exit /b
echo ^)
echo cd /d "Note-ify"
echo start noteify.exe
echo pause
) > start_noteify.bat
)

:: -------------------------
:: Create start_ollama.bat
:: -------------------------
if not exist start_ollama.bat (
(
echo @echo off
echo tasklist ^| find /i "ollama.exe" ^>nul
echo if %%errorlevel%%==0 (
echo     echo Ollama already running.
echo     pause
echo     exit /b
echo ^)
echo echo Starting Ollama server...
echo start "" ollama serve
echo pause
) > start_ollama.bat
)

:: -------------------------
:: Create start_whisper.bat
:: -------------------------
if not exist start_whisper.bat (
(
echo @echo off
echo tasklist ^| find /i "whisper-server.exe" ^>nul
echo if %%errorlevel%%==0 (
echo     echo Whisper server already running.
echo     pause
echo     exit /b
echo ^)
echo cd /d "whisper.cpp\build\bin"
echo start whisper-server.exe
echo pause
) > start_whisper.bat
)

:: -------------------------
:: Launch each in new window
:: -------------------------
start "Noteify" cmd /k start_noteify.bat
start "Ollama"  cmd /k start_ollama.bat
start "Whisper" cmd /k start_whisper.bat
