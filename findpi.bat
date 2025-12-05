@echo off
cls
for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get DefaultIPGateway /value | find "I" "') do set mip=%%~a
for /f "delims=" %%i in ('echo %mip%') do set subip=%%i
for %%i in (%subip%) do set subip=%%~ni
echo Premiere etape decouverte reseau %subip% soyez patient && echo First step network discovering %subip% be patient
for /L %%i in (0,1,255) do @ping -n 1 -l 1 -w 1 %subip%.%%i -4 | findstr -m "=32"

FOR /F "delims=" %%r IN ('"arp -a|findstr b8-27-eb"') DO SET result1=%%r
FOR /F "delims=" %%s IN ('"arp -a|findstr dc-a6-32"') DO SET result2=%%s

echo ####################### RASPBERRY #######################
IF NOT "%result1%"=="" ECHO %result1%
IF NOT "%result2%"=="" ECHO %result2%
echo #########################################################
pause
