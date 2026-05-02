@echo off
echo ========================================
echo yt-dlp Test Script for SOUNDY
echo ========================================
echo.

echo [1] Checking common yt-dlp locations...
echo.

set FOUND=0

REM Check common paths
if exist "%USERPROFILE%\yt-dlp.exe" (
  echo [OK] Found: %USERPROFILE%\yt-dlp.exe
  "%USERPROFILE%\yt-dlp.exe" --version
  set FOUND=1
  goto :found
)

if exist "%USERPROFILE%\yt-dlp" (
  echo [OK] Found: %USERPROFILE%\yt-dlp
  "%USERPROFILE%\yt-dlp" --version
  set FOUND=1
  goto :found
)

if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\yt-dlp.exe" (
  echo [OK] Found: %LOCALAPPDATA%\Microsoft\WindowsApps\yt-dlp.exe
  "%LOCALAPPDATA%\Microsoft\WindowsApps\yt-dlp.exe" --version
  set FOUND=1
  goto :found
)

echo [INFO] Not found in common locations, checking PATH...
where yt-dlp 2>nul
if %ERRORLEVEL% == 0 (
  echo [OK] Found in PATH
  yt-dlp --version
  set FOUND=1
  goto :found
)

if %FOUND% == 0 (
  echo [ERROR] yt-dlp NOT found!
  echo.
  echo Install options:
  echo 1. Download from: https://github.com/yt-dlp/yt-dlp/releases
  echo 2. Save to: %USERPROFILE%\yt-dlp.exe
  echo 3. Or install via: winget install yt-dlp
  goto :end
)

:found
echo.
echo ========================================
echo [2] Testing YouTube search...
echo ========================================
echo.

REM Use the found path
if exist "%USERPROFILE%\yt-dlp.exe" (
  set YTDLP="%USERPROFILE%\yt-dlp.exe"
) else if exist "%USERPROFILE%\yt-dlp" (
  set YTDLP="%USERPROFILE%\yt-dlp"
) else (
  set YTDLP=yt-dlp
)

echo Searching for "test song audio"...
%YTDLP% "ytsearch1:test song audio" --dump-json --skip-download --no-download --quiet > test_search.json 2>&1

if %ERRORLEVEL% == 0 (
  echo [OK] YouTube search works!
  echo Search result:
  findstr "title" test_search.json | head -1
  del test_search.json
) else (
  echo [ERROR] YouTube search failed!
  type test_search.json
  del test_search.json
)

:end
echo.
echo ========================================
echo Test complete!
echo ========================================
pause
