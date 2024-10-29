@echo off
setlocal enabledelayedexpansion

:: Set console mode
mode 800

echo.
echo ============================================================
echo            Welcome to Windows Installation on ARM64 
echo ============================================================
echo.
echo.
echo ============================================================
echo             Searching for the index value 
echo                 of "Windows Image"...
echo ============================================================
echo.

:: Initialize variables
set imageFile=
set targetDrive=

:: Loop through all drives to find the image file
for %%G in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%G:\installer\install.esd (
        set imageFile=%%G:\installer\install.esd
        set targetDrive=%%G:
        set flashboot=%%G:\installer\sta.exe -n
        goto :found
    ) else if exist %%G:\installer\install.wim (
        set imageFile=%%G:\installer\install.wim
        set flashboot=%%G:\installer\sta.exe -n
        set targetDrive=%%G:
        goto :found
    )
)

echo Neither ESD nor WIM file found on any drive.
echo Take picture of error, force Reboot and ask for help...
call %flashboot%
pause
exit /b 1

:found
echo.
echo ============================================================
echo           Image file found at %imageFile%
echo           Windows drive set to %targetDrive%
echo ============================================================
echo.

echo ============================================================
echo Serching index of Windows in the following order ........
echo       1.  Windows 11 Pro
echo       2.  Windows 11 IoT Enterprise LTSC
echo       3.  Windows 10 Pro
echo       4.  Windows 11 Home
echo ============================================================
echo.

:: Initialize index variable
set index=
set Name=""

:: Find the index for Windows 11 Pro
for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
    set currentIndex=%%i
    for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Name : Windows 11 Pro"') do (
        set index=%%i
        set Name="Windows 11 Pro"
        goto :indexFound
    )
)
if "%index%"=="" echo "Windows 11 Pro not found in the image file."

:: Find the index for Windows 11 IoT Enterprise LTSC
if "%index%"=="" (
    for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
        set currentIndex=%%i
        for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Name : Windows 11 IoT Enterprise LTSC"') do (
            set index=%%i
            set Name="Windows 11 IoT Enterprise LTSC"
            goto :indexFound
        )
    )
)
if "%index%"=="" echo "Windows 11 IoT Enterprise LTSC not found in the image file."

:: Find the index for Windows 10 Pro
if "%index%"=="" (
    for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
        set currentIndex=%%i
        for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Name : Windows 10 Pro"') do (
            set index=%%i
            set Name="Windows 10 Pro"
            goto :indexFound
        )
    )
)
if "%index%"=="" echo "Windows 10 Pro not found in the image file."

:: Find the index for Windows 11 Home
if "%index%"=="" (
    for /f "tokens=2 delims=: " %%i in ('dism /Get-WimInfo /WimFile:%imageFile% ^| findstr /i /c:"Index :"') do (
        set currentIndex=%%i
        for /f "tokens=*" %%j in ('dism /Get-WimInfo /WimFile:%imageFile% /Index:%%i ^| findstr /i /c:"Name : Windows 11 Home"') do (
            set index=%%i
            set Name="Windows 11 Home"
            goto :indexFound
        )
    )
)
if "%index%"=="" (
    echo "Index not found for the specified Windows version."
	echo "Please check your Windows image and restart installation."
	call %flashboot%
    pause
    exit /b
)

:indexFound

echo ============================================================
echo           Index value %index% found for %Name% 
echo           starting winddows installation.....
echo ============================================================
echo.

:: Apply the selected index to the target drive
echo Applying image to %targetDrive%...
dism /Apply-Image /ImageFile:%imageFile% /Index:%index% /ApplyDir:%targetDrive%
echo Image applied successfully!

echo.
echo ============================================================
echo           Assigning drive letter for 
echo                  bootloader...
echo ============================================================
echo.

:: List all volumes and find the FAT32 volume with label containing ESP
set foundESP=false
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
    echo Take picture of error, force Reboot and ask for help.
    call %flashboot%
    pause
    exit /b 1
)

:volFound
echo Found FAT32 volume with ESP or PE, Volume Number %VolumeNumber%

:: Format the volume, assign the drive letter S, and label it "ESPWOA"
(
    echo select volume %VolumeNumber%
    echo format fs=fat32 quick label=ESPWOA
    echo assign letter=S
) | diskpart

echo.
echo ============================================================
echo           %VolumeNumber% has been formatted with FAT32,
echo           Assigned letter S, and labeled "ESPWOA".
echo ============================================================
echo.
echo.
echo ============================================================
echo           Creating bootloader file...
echo ============================================================
echo.
bcdboot %targetDrive%\windows /s S: /f UEFI

echo.
echo ==========================================================
echo           Windows installation process 
echo                    completed!
echo ==========================================================
echo.
echo.
echo ==========================================================
echo           Now performing driver installation...
echo ==========================================================

:: Searching for an XML file in the target directory and renaming it to sog.xml
set xmlFound=false
for %%F in (%targetDrive%\installer\Driver\definitions\Desktop\ARM64\Internal\*.xml) do (
    ren "%%F" sog.xml
    set xmlFound=true
    goto :fileFound
)

if "!xmlFound!"=="false" (
    echo No XML files found in %targetDrive%\installer\Driver\definitions\Desktop\ARM64\Internal\.
    %flashboot%
    pause
    exit /b 1
)

:fileFound
echo XML file found and renamed to sog.xml.

:continue
call "X:\DriverInstaller\DriverInstaller.lnk"

echo.
echo ==========================================================
echo Installation Completd.Rebooting in Windows in 5 seconds. 
echo This script is written by Kumar-Jy, telegram : @kumar_jy
echo ==========================================================
shutdown /r /t 5

echo.
echo ==========================================================
echo           Cleaning Installation File........
echo ==========================================================
cd %targetDrive%
rmdir /s /q "%targetDrive%\installer"
