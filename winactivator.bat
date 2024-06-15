@echo off
powershell.exe -command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID"
pause