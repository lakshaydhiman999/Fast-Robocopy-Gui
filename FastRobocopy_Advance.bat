@echo off
:: ============================================================
:: Project: Fast Robocopy GUI - Advance
:: Description: High-speed multithreaded copy tool for Windows
:: License: MIT
:: ============================================================

setlocal enabledelayedexpansion
title Fast Robocopy GUI - Advance [MT:32]

:: --- Auto-Administrator Rights ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Requesting Administrator privileges...
    powershell start-process '%0' -verb runas
    exit /b
)

:: Fix potential directory issues
pushd "%~dp0"

:MENU
cls
echo ===============================================
echo      FAST ROBOCOPY GUI - ADVANCE EDITION
echo ===============================================
echo  [1] Folder Copy (Complete Directory)
echo  [2] File Copy   (Single/Multiple Selection)
echo  [3] Exit
echo ===============================================
set /p mode="Choose an option (1-3): "

if "%mode%"=="1" goto FOLDER_MODE
if "%mode%"=="2" goto FILE_MODE
if "%mode%"=="3" exit
goto MENU

:FOLDER_MODE
echo.
echo [PROMPT] Select Source Folder...
for /f "delims=" %%I in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select Source'; $null = $f.ShowDialog(); $f.SelectedPath"') do set "source=%%I"
if "%source%"=="" goto MENU

echo [PROMPT] Select Destination...
for /f "delims=" %%I in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select Destination'; $null = $f.ShowDialog(); $f.SelectedPath"') do set "dest=%%I"
if "%dest%"=="" goto MENU

for %%A in ("%source%") do set "fName=%%~nxA"
robocopy "%source%" "%dest%\%fName%" /MT:32 /E /ZB /ETA /R:3 /W:5
goto END

:FILE_MODE
echo.
echo [PROMPT] Select Files (Use Ctrl for multi-select)...
for /f "delims=" %%I in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Multiselect = $true; $null = $f.ShowDialog(); $f.FileNames"') do (
    set "fList=%%I"
    if not defined dPath (
        echo [PROMPT] Select Destination Folder...
        for /f "delims=" %%D in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $null = $f.ShowDialog(); $f.SelectedPath"') do set "dPath=%%D"
    )
    if "!dPath!"=="" (set "dPath=" & goto MENU)
    for %%A in ("!fList!") do (
        set "fDir=%%~dpA"
        set "fName=%%~nxA"
        robocopy "!fDir!." "!dPath!." "!fName!" /MT:32 /ZB /ETA /R:3 /W:5
    )
)
set "dPath="
goto END

:END
echo.
echo 
echo ===============================================
echo OPERATION COMPLETE!
echo ===============================================
pause
goto MENU
