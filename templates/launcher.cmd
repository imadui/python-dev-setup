@echo off
setlocal DisableDelayedExpansion
set "GIT_ROOT="
for /f "delims=" %%R in ('git rev-parse --show-toplevel 2^>nul') do set "GIT_ROOT=%%R"
if not defined GIT_ROOT (
    >&2 echo ERROR: Run this command from inside a Git repository.
    exit /b 1
)
set "GIT_ROOT=%GIT_ROOT:/=\%"
set "VENV_PYTHON=%GIT_ROOT%\.venv\Scripts\python.exe"
if not exist "%VENV_PYTHON%" (
    >&2 echo ERROR: Missing Git-root virtual environment: "%VENV_PYTHON%"
    exit /b 1
)
if not exist "%~dp0launcher_runner.py" (
    >&2 echo ERROR: launcher_runner.py is missing beside this script.
    exit /b 1
)
"%VENV_PYTHON%" "%~dp0launcher_runner.py" %*
exit /b %ERRORLEVEL%
