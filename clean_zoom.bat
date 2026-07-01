@echo off
setlocal enabledelayedexpansion

title ZOOM Transcript Cleaner

echo.
echo ==========================================
echo ZOOM Transcript Cleaner
echo ==========================================
echo.

REM --- Check input file ---
if "%~1"=="" (
  echo [HOW TO USE]
  echo Drag and drop a text file onto this bat file.
  echo.
  echo ** Double-clicking will not work **
  echo.
  pause
  exit /b 1
)

set "input=%~1"
set "output=%~dpn1_cleaned.txt"

echo [INFO]
echo Input : %input%
echo Output: %output%
echo.

REM --- Check file exists ---
if not exist "%input%" (
  echo [ERROR] File not found
  echo.
  pause
  exit /b 1
)

echo [PROCESSING]
echo.
echo Reading file...

REM --- Execute PowerShell ---
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $content = $null; try { $content = Get-Content -Path '%input%' -Encoding UTF8 -Raw; Write-Host 'OK: UTF-8 detected'; } catch { try { $content = Get-Content -Path '%input%' -Encoding Default -Raw; Write-Host 'OK: Shift-JIS detected'; } catch { throw 'Failed to detect encoding'; } }; if($content -eq $null) { throw 'Failed to read file'; }; $lines = $content -split '\r?\n'; $cleaned = @(); foreach($line in $lines) { if($line -notmatch '^\[.*?\]\s+\d{2}:\d{2}:\d{2}\s*$') { $trimmed = $line.Trim(); if($trimmed -ne '') { $cleaned += $trimmed; } } }; Write-Host 'OK: Removed speaker names and timestamps ('$cleaned.Count' lines)'; $result = $cleaned -join ' '; $result = $result -replace '\s+', ' '; Write-Host 'OK: Converted newlines to spaces'; [System.IO.File]::WriteAllText('%output%', $result, [System.Text.Encoding]::UTF8); Write-Host 'OK: Saved file (UTF-8)'; Write-Host ''; Write-Host 'Characters:' $result.Length; } catch { Write-Host '[ERROR]' -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Red; exit 1; }"

if %ERRORLEVEL% EQU 0 (
  echo.
  echo ==========================================
  echo SUCCESS!
  echo ==========================================
  echo.
  echo Output: %output%
  echo Encoding: UTF-8
  echo.
) else (
  echo.
  echo ==========================================
  echo FAILED
  echo ==========================================
  echo.
)

pause
