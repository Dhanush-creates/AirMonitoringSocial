@echo off
rem Runs the analysis without the dashboard.
rem   analyze.bat                        the input in config\settings.yaml
rem   analyze.bat data\my_posts.jsonl    another file (more options: python monitor.py run --help)
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe (echo Run setup.bat first. & pause & exit /b 1)
if "%~1"=="" (
  .venv\Scripts\python.exe monitor.py run
) else (
  .venv\Scripts\python.exe monitor.py run --input "%~1" %2 %3 %4 %5 %6 %7 %8 %9
)
pause
