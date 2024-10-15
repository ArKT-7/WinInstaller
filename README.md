# WinInstaller
> copyright © 2023 2024
### Description
Windows Installer flashable zip [without PC] for supported ARM64 device.

### Perquisite 
- You should have Orange Fox / TWRP recovery installed
- There is already created necessary partitionn for windows installation.
- Make sure ESP partition size is not less then 350MB

### Instruction
- Download this repository as zip and unpack it. 
- Open install.bat in any text editor, find diskpart section and change esp disk number as per your android partition.
- Download pe file from release tag and add to the unpacked folder
- Downlod and place uefi.img of your device in unpacked folder
- Select all file/folder and repack it as zip file.
- Now your WnInstalleer Zip file is ready.
- Download Windows ESD image and Drivers.zip (both the file should be in defauld `download` folder in your device.
- Must rename your device's drivers.zip file to `Driver.zip` (letter is case sensitive) or it will failed to install it.  
- Flash/sideload it using any custom recovery (Orangefox recommended).
- enjoy !
##
Note :- All zip file should be packed without compression.
