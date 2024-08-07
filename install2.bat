@echo off
setlocal enabledelayedexpansion


:: Set the ESD file location
set esdFile="W:\installer\install.esd"

:: Initialize index variable
set index=

:: Get the index number for "Windows 11 Pro"
for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%esdFile% ^| findstr /i /c:"Index :"') do (
    set currentIndex=%%i
    for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%esdFile% /Index:%%i ^| findstr /i /c:"Description : Windows 11 Pro"') do (
        set index=%%i
        goto :found
    )
)

:found
:: Check if the index was found
if "%index%"=="" (
    echo "Windows 11 Pro" not found in the ESD file.
    pause
    exit /b
)

:: Debugging information
echo Debug: Final index value is %index%

:: Apply the selected index to the W:\ drive
dism /Apply-Image /ImageFile:%esdFile% /Index:%index% /ApplyDir:W:\

echo.
echo Image applied successfully!


echo. 
echo Performing Driver Installation ... 
dism /image:W:\ /add-driver /Driver:W:\installer\Driver /recurse

echo. 
echo Driver Installation completed. 

echo. 
echo Creating Bootloader file ...
bcdboot W:\windows /s S: /f UEFI

echo. 
echo Bootllader file creation completed.

echo. 
echo boot loader configuration started ...
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} testsigning on
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} nointegritychecks on
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} recoveryenabled no

echo.
echo boot loader configration completed.
echo.

echo Performing touchscreen Fix ...
reg load HKLM\OFFLINE W:/Windows/System32/config/SYSTEM

reg add "HKLM\OFFLINE\TOUCH\SCREENPROPERTIES" /v TouchPhysicalWidth /t REG_DWORD /d 0x0000438
reg add "HKLM\OFFLINE\TOUCH\SCREENPROPERTIES" /v TouchPhysicalHeight /t REG_DWORD /d 0x00008c6
reg add "HKLM\OFFLINE\TOUCH\SCREENPROPERTIES" /v DisplayPhysicalWidth /t REG_DWORD /d 0x0000438
reg add "HKLM\OFFLINE\TOUCH\SCREENPROPERTIES" /v DisplayPhysicalHeight /t REG_DWORD /d 0x00008c6
reg add "HKLM\OFFLINE\TOUCH\SCREENPROPERTIES" /v DisplayViewableWidth /t REG_DWORD /d 0x0000438
reg add "HKLM\OFFLINE\TOUCH\SCREENPROPERTIES" /v DisplayViewableHeight /t REG_DWORD /d 0x00008c6

reg unload HKLM\OFFLINE

echo. 
echo touchscreen fixing completed.

echo cleaning installation file.
rmdir /s /q W:\installer
echo.
echo cleaning installation file completed.
echo.
echo all process completed suessfully
echo. 
echo Now system will reboot in 5 second
echo. 
echo This Script Written by Kumar_Jy, Telegram ID : @Kumar_Jy , Github : http://github/Kumar-Jy
echo. 
exit
