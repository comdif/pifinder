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

rem --- Ping sweep to populate the ARP table (fast, uses 32 simultaneous processes) ---
set "batchSize=32"
set /a cnt=0

for /L %%i in (1,1,254) do (
  start /b "" ping -n 1 -w 100 %subnet%.%%i >nul
  set /a cnt+=1
  if !cnt! GEQ %batchSize% (
    call :wait_for_pings
    set /a cnt=0
  )
)
rem --- wait for any remaining pings
if %cnt% NEQ 0 call :wait_for_pings

goto :continue

:wait_for_pings
  rem wait until no ping.exe processes remain
  :waitloop
  tasklist /fi "imagename eq ping.exe" /nh | find /i "ping.exe" >nul
  if errorlevel 1 (
    rem none found -> done waiting
  ) else (
    timeout /t 1 >nul
    goto waitloop
  )
  goto :eof

:continue
rem --- now arp -a will see populated ARP entries

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
