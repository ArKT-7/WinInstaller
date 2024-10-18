@echo off
setlocal enabledelayedexpansion

:: Set console mode
mode 800

echo.
echo ==========================================================
echo Searching for the index value of "Windows Image"...
echo ==========================================================
echo.

:: Initialize variables
set imageFile=
set targetDrive=

:: Loop through all drives to find the image file
for %%G in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%G:\installer\install.esd (
        set imageFile=%%G:\installer\install.esd
        set targetDrive=%%G:
        goto :found
    ) else if exist %%G:\installer\install.wim (
        set imageFile=%%G:\installer\install.wim
        set targetDrive=%%G:
        goto :found
    )
)

echo Neither ESD nor WIM file found on any drive.
pause
exit /b

:found
echo.
echo ==========================================================
echo Image file found at %imageFile%
echo Target drive set to %targetDrive%
echo ==========================================================
echo.

:: Initialize index variable
set index=
set description=""

:: Find the index for Windows 11 Pro
for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
    set currentIndex=%%i
    for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Description : Windows 11 Pro"') do (
        set index=%%i
        set description="Windows 11 Pro"
        goto :indexFound
    )
)
if "%index%"=="" echo "Windows 11 Pro not found in the image file."

:: Find the index for Windows 11 IoT Enterprise LTSC
if "%index%"=="" (
    for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
        set currentIndex=%%i
        for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Description : Windows 11 IoT Enterprise LTSC"') do (
            set index=%%i
            set description="Windows 11 IoT Enterprise LTSC"
            goto :indexFound
        )
    )
)
if "%index%"=="" echo "Windows 11 IoT Enterprise LTSC not found in the image file."

:: Find the index for Windows 10 Pro
if "%index%"=="" (
    for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
        set currentIndex=%%i
        for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Description : Windows 10 Pro"') do (
            set index=%%i
            set description="Windows 10 Pro"
            goto :indexFound
        )
    )
)
if "%index%"=="" echo "Windows 10 Pro not found in the image file."

:: Find the index for Windows 11 Home
if "%index%"=="" (
    for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
        set currentIndex=%%i
        for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Description : Windows 11 Home"') do (
            set index=%%i
            set description="Windows 11 Home"
            goto :indexFound
        )
    )
)
if "%index%"=="" (
    echo "Windows 11 Home not found in the image file."
    pause
    exit /b
)

:indexFound
echo %description% found at index %index%

:: Debugging information
echo.
echo ==========================================================
echo Final index value is %index%
echo ==========================================================
echo.

:: Apply the selected index to the target drive
echo Applying image to %targetDrive%...
dism /Apply-Image /ImageFile:%imageFile% /Index:%index% /ApplyDir:%targetDrive%
echo Image applied successfully!
echo.
echo ==========================================================
echo Assigning drive letter for bootloader...
echo ==========================================================
echo.

:: List all volumes and find the FAT32 volume with label containing ESP
for /f "tokens=2,3,4 delims= " %%A in ('echo list volume ^| diskpart ^| findstr /I "FAT32" ^| findstr /I "ESP"') do (
    set VolumeNumber=%%A
    set foundESP=true
    goto :volFound
)

:: If no FAT32 ESP volume found, search for PE
if not !foundESP! == true (
    echo No FAT32 ESP volume found. Searching for PE...
    for /f "tokens=2,3,4 delims= " %%B in ('echo list volume ^| diskpart ^| findstr /I "FAT32" ^| findstr /I "PE"') do (
        set VolumeNumber=%%B
        goto :volFound
    )
)

if not defined VolumeNumber (
    echo No FAT32 ESP or PE volume found.
    exit /b 1
)

:volFound
echo Found FAT32 volume with ESP or PE, Volume Number %VolumeNumber%

:: Format the volume, assign the drive letter S, and label it "ESPWOA"
(
    echo select volume %VolumeNumber%
    echo format fs=fat32 quick label=ESPNABU
    echo assign letter=S
) | diskpart

echo.
echo Volume has been formatted with FAT32, assigned to S, and labeled "ESPWOA".
echo.
echo ==========================================================
echo Creating bootloader file...
echo ==========================================================
echo.

bcdboot %targetDrive%\windows /s S: /f UEFI

echo.
echo ==========================================================
echo Windows installation process completed!
echo ==========================================================
echo.

echo ==========================================================
echo Now performing driver installation...
echo ==========================================================
call "X:\DriverInstaller\DriverInstaller.lnk"

echo.
echo ==========================================================
echo Removing installer directory...
echo ==========================================================
cd %targetDrive%\
rmdir /s /q "%targetDrive%\installer"
echo.

echo ==========================================================
echo Rebooting in 5 seconds...
echo ==========================================================
echo.

echo this script is written by https://gitHub.com/Kumar-Jy
