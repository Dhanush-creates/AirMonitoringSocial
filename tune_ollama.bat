@echo off
rem Lets Ollama use the GPU fully. Run once, then quit Ollama (system tray) and start it again.
rem   tune_ollama.bat      4 requests at once (12-16 GB GPUs such as the RTX 5070)
rem   tune_ollama.bat 8    8 requests at once (24 GB GPUs such as the RTX 4090)
rem It sets user environment variables; remove them in Windows "Edit environment variables" to undo.
set PARALLEL=%~1
if "%PARALLEL%"=="" set PARALLEL=4
setx OLLAMA_NUM_PARALLEL %PARALLEL%
setx OLLAMA_FLASH_ATTENTION 1
setx OLLAMA_KV_CACHE_TYPE q8_0
echo.
echo Done. Quit Ollama from the system tray and start it again so it picks these up.
pause
