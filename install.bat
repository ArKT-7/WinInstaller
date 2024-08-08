:: Copyright (c) 2023-24
:: This Script Written by t.me/Kumar_Jy and only work if you follow proper github guide (https://github.com/Kumar-Jy/Windows-in-(device-Name)-Without-PC)


@echo off
setlocal enabledelayedexpansion

:: Set the console mode
mode 800

:: Set the ESD file location
set esdFile="C:\installer\install.esd"

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

:: Apply the selected index to the C:\ drive
dism /Apply-Image /ImageFile:%esdFile% /Index:%index% /ApplyDir:C:\

echo.
echo Image applied successfully!

echo.
echo Performing Driver Installation...
dism /image:C:\ /add-driver /Driver:C:\installer\Driver /recurse

echo.
echo Driver Installation completed.
echo.

:: Disk operations using diskpart
(
echo Rescan
echo sel dis 0
echo sel par 31
echo format quick fs=fat32 label="ESP"
echo assign letter=S
) | diskpart

echo driver letter assigned successfully
echo.

echo Creating Bootloader file...
bcdboot C:\windows /s S: /f UEFI

echo.
echo Bootloader file creation completed.

echo. 
echo boot loader configuration started ...
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} testsigning on
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} nointegritychecks on
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} recoveryenabled no

echo.
echo boot loader configration completed.
echo.

echo cleaning installation file.
rmdir /s /q C:\installer
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
