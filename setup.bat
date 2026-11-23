@echo off
rem AIRMONITORSOCIAL setup: creates .venv and installs the libraries listed in requirements\
rem   setup.bat        core + analysis + dashboard + requirements\my_libraries.txt
rem   setup.bat gpu    also the GPU tools (PyTorch for CUDA, about 3 GB download)
cd /d "%~dp0"
where python >nul 2>nul || (echo Python 3.10 or newer is needed: https://www.python.org/downloads/ & pause & exit /b 1)
if not exist .venv\Scripts\python.exe (
  echo Creating .venv ...
  python -m venv .venv || (pause & exit /b 1)
)
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\python.exe -m pip install -r requirements\core.txt -r requirements\analysis.txt -r requirements\ui.txt -r requirements\my_libraries.txt || (pause & exit /b 1)
if /i "%~1"=="gpu" (
  .venv\Scripts\python.exe -m pip install -r requirements\gpu.txt || (pause & exit /b 1)
)
echo.
.venv\Scripts\python.exe monitor.py doctor
echo.
echo Setup finished. Start the dashboard with dashboard.bat
pause
