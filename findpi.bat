@echo off
cls
for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get DefaultIPGateway /value | find "I" "') do set mip=%%~a
for /f "delims=" %%i in ('echo %mip%') do set subip=%%i
for %%i in (%subip%) do set subip=%%~ni
echo First step network discovering %subip% be patient
for /L %%i in (0,1,255) do @ping -n 1 -l 1 -w 1 %subip%.%%i -4 | findstr -m "=32"

## TEST All Raspberry PI MAC sourced from Wiresharck ##
FOR /F "delims=" %%r IN ('"arp -a|findstr 28-cd-c1"') DO SET result1=%%r
FOR /F "delims=" %%s IN ('"arp -a|findstr 2c-cf-67"') DO SET result2=%%s
FOR /F "delims=" %%t IN ('"arp -a|findstr 3a-35-41"') DO SET result3=%%t
FOR /F "delims=" %%u IN ('"arp -a|findstr 88-a2-9e"') DO SET result4=%%u
FOR /F "delims=" %%v IN ('"arp -a|findstr b8-27-eb"') DO SET result5=%%v
FOR /F "delims=" %%w IN ('"arp -a|findstr d8-3a-dd"') DO SET result6=%%w
FOR /F "delims=" %%x IN ('"arp -a|findstr dc-a6-32"') DO SET result7=%%x
FOR /F "delims=" %%y IN ('"arp -a|findstr e4-5f-01"') DO SET result8=%%y

echo ####################### RASPBERRY FOUND #######################
IF NOT "%result1%"=="" ECHO %result1%
IF NOT "%result2%"=="" ECHO %result2%
IF NOT "%result3%"=="" ECHO %result3%
IF NOT "%result4%"=="" ECHO %result4%
IF NOT "%result5%"=="" ECHO %result5%
IF NOT "%result6%"=="" ECHO %result6%
IF NOT "%result7%"=="" ECHO %result7%
IF NOT "%result8%"=="" ECHO %result8%
echo ###############################################################


pause
