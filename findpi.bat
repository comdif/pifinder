@echo off
setlocal enabledelayedexpansion
cls

rem --- Get default gateway from IPv4 route table (robust) ---
for /f "tokens=3" %%A in ('route print -4 ^| findstr /C:" 0.0.0.0 "') do (
  set "mip=%%A"
  goto :gotgw
)
:gotgw
if not defined mip (
  echo Could not determine default gateway.
  pause
  exit /b 1
)

rem --- Extract first three octets to form the subnet prefix (e.g. 192.168.1) ---
for /f "tokens=1-3 delims=." %%A in ("%mip%") do set "subnet=%%A.%%B.%%C"

echo First step: network discovery on %subnet%.0/24 please be patient.

rem --- Ping sweep to populate the ARP table (quiet, fast) ---
for /L %%i in (1,1,254) do (
  ping -n 1 -w 1 %subnet%.%%i >nul
)

rem --- MAC prefixes to look for (treated as an "array") ---
set "macs=28-cd-c1 2c-cf-67 3a-35-41 88-a2-9e b8-27-eb d8-3a-dd dc-a6-32 e4-5f-01"

echo.
echo ####################### RASPBERRY FOUND #######################
set "found=0"
for %%m in (%macs%) do (
  for /f "delims=" %%r in ('arp -a ^| findstr /i "%%m"') do (
    echo %%r
    set "found=1"
  )
)

if "!found!"=="0" echo No Raspberry Pi MAC prefixes found.
echo ###############################################################
pause
endlocal
