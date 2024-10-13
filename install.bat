:: Copyright (c) 2023-24
:: This Script Written by t.me/Kumar_Jy and only work if you follow proper github guide (https://github.com/Kumar-Jy/Windows-in-.........-Without-PC)

echo off
setlocal enabledelayedexpansion

:: Set the console mode
mode 800

REM Set the image file location
set fileLocation="C:\installer\install"

REM Check if ESD or WIM file exists
if exist %fileLocation%.esd (
    set imageFile=%fileLocation%.esd
) else if exist %fileLocation%.wim (
    set imageFile=%fileLocation%.wim
) else (
    echo Neither ESD nor WIM file found.
    pause
    exit /b
)

REM Initialize index variable
set index=

REM Get the index number for "Windows 11 Pro"
for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
    set currentIndex=%%i
    for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Description : Windows 11 Pro"') do (
        set index=%%i
        goto :found
    )
)

:found
REM Check if the index was found
if "%index%"=="" (
    echo "Windows 11 Pro" not found in the image file.
    pause
    exit /b
)

REM Debugging information
echo Final index value is %index%

REM Apply the selected index to the C:\ drive
dism /Apply-Image /ImageFile:%imageFile% /Index:%index% /ApplyDir:C:\

echo Image applied successfully!

echo.
echo Performing Driver Installation...
dism /image:C:\ /add-driver /Driver:C:\installer\Driver /recurse

echo.
echo Driver Installation completed.
echo.

echo assigning drive letter for bootloader.

REM List all volumes and find the first FAT32 volume
for /f "tokens=2,3 delims= " %%A in ('echo list volume ^| diskpart ^| findstr /C:"FAT32 "') do (
    set VolumeNumber=%%A
    goto :found
)

echo No FAT32 volume found.
exit /b 1

:found
echo Found FAT32 volume, Volume Number %VolumeNumber%

REM Format the volume and assign the drive letter S
(
    echo select volume %VolumeNumber%
    echo format fs=fat32 quick
    echo assign letter=S
) | diskpart

echo Volume has been formatted with FAT32 and assigned to S.

echo.

echo Creating Bootloader file...
bcdboot C:\windows /s S: /f UEFI

echo.
echo Bootloader file creation completed

echo. 
echo boot loader configuration started ...
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} testsigning on
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} nointegritychecks on
bcdedit /store S:\efi\microsoft\boot\bcd /set {Default} recoveryenabled no

echo.
echo boot loader configration completed.
echo.
echo all process completed suessfully
echo. 
echo Now system will reboot in 5 second
echo. 
echo This Script Written by Kumar_Jy, Telegram ID : @Kumar_Jy , Github : http://github/Kumar-Jy
echo.
C:/rmdir.bat
