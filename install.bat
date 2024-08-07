:: Copyright (c) 2023-24
:: This Script Written by t.me/Kumar_Jy and only work if you follow proper github guide (https://github.com/Kumar-Jy/Windows-in-PocoF1-Without-PC)


(echo Rescan
echo sel dis 0
echo sel par 21
echo format quick fs=fat32 label="ESPF1"
echo assign letter=S
echo sel par 23
echo assign letter=W
)  | diskpart

echo off

mode 800

echo.

echo
W:\install2.bat

