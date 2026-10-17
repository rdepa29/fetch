@echo off
setlocal enabledelayedexpansion

set "VERSION=dev"
for /f "usebackq delims=" %%v in ("%~dp0VERSION") do set "VERSION=%%v"
set "CODENAME=Overclocked ASCII"
set "OSNAME=Windows"

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
  set "ARCH=x86_64"
) else if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
  set "ARCH=aarch64"
) else (
  set "ARCH=%PROCESSOR_ARCHITECTURE%"
)

gcc -O2 -Wall ^
  -DFETCH_VERSION="\"%VERSION%\"" ^
  -DFETCH_CODENAME="\"%CODENAME%\"" ^
  -DFETCH_ARCH="\"%ARCH%\"" ^
  -DFETCH_OS="\"%OSNAME%\"" ^
  -o "%~dp0fetch.exe" "%~dp0fetch.c" -lm -lws2_32 -liphlpapi -lpsapi

if errorlevel 1 (
  echo Build failed.
  exit /b 1
)
echo Built: fetch.exe

rem Install to a directory on PATH so "fetch" works from anywhere.
set "BINDIR=%USERPROFILE%\bin"
if not exist "%BINDIR%" mkdir "%BINDIR%"
copy /Y "%~dp0fetch.exe" "%BINDIR%\fetch.exe" >nul
if errorlevel 1 (
  echo Warning: could not copy to "%BINDIR%\fetch.exe".
  exit /b 0
)
echo Installed: "%BINDIR%\fetch.exe"

rem Make sure the install dir is on the user PATH.
powershell -NoProfile -Command "$b=[Environment]::GetEnvironmentVariable('Path','User'); if (($b -split ';') -notcontains '%BINDIR%') { [Environment]::SetEnvironmentVariable('Path', ($b.TrimEnd(';') + ';%BINDIR%'), 'User'); Write-Host 'Added %BINDIR% to your user PATH. Restart your terminal for it to take effect.' }"
echo You can now run: fetch
