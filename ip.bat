@echo off

REM --> Taken from user399109 on StackOverflow
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

echo Choix de la carte reseau:
echo [1] Ethernet
echo [2] Wi-Fi

:choiceint
SET /P C=[1 or 2]? 
if [%C%]==[1] set int=Ethernet
if [%C%]==[2] set int=Wi-Fi
if [%C%]==[1] goto type
if [%C%]==[2] goto type
goto choiceint
echo ================================

:type

echo Choix du type d'adressage:
echo [1] Set Static
echo [2] Set DHCP

:choicetype
SET /P C=[1 or 2]? 
if [%C%]==[1] goto A
if [%C%]==[2] goto B
goto choicetype
echo ================================


:A
@echo off
set /P addr=Adresse IP? 
set /P mask=Masque? 
set /P gateway=Gateway? 
netsh interface ip set address "%int%" static %addr% %mask% %gateway%
netsh interface ip add dns "%int%" addr="1.1.1.1"
netsh interface ip show config "%int%"
goto end

:B
@echo off
echo Enabling DHCP
netsh interface ip set address "%int%"  source=dhcp
netsh interface ip set dnsservers "%int%" source=dhcp
echo Chargement...
ipconfig /renew > nul
netsh interface ip show config "%int%"
goto end

:end

pause > nul