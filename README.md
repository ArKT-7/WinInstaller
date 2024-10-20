# WinInstaller
© 2023–2024

## Description
Windows Installer flashable zip [without PC] for supported ARM64 devices.

### Prerequisites
- All necessary partition for Windows installation ( such as win and esp) should already be created
-	Ensure the ESP partition size is not smaller then 350MB

### Preparation
- Download this repository as a zip and unpack it.
-	Download the pe.img from the release tag and add it to the unpacked folder.
-	Place the uefi.img of your device in the unpacked folder.
-	Download the Drivers pack for your device, unpack it, go to the folder `Driver\definitions\Desktop\ARM64\Internal` and rename the XML file to `sog.xml`. Select all files and pack as Driver.zip.
- Place the modified Driver.zip into the unpacked WinInstaller folder. It should contains Driver.zip, sog.img, uefi.img, and META-INF (all file and folder names are case-sensitive).
- Select all files/folders and repack them as a zip file. Your WinInstaller.zip is now ready.

### Flashing Instructions
- Download the Windows ESD image (it should be in the default download folder in your device memory).
- Boot to TWRP/OrangeFox recovery and flash/sideload WinInstaller.zip.
- The device will automatically reboot to WinPE and begin the Windows installation.
> Important Notes
- Ensure all files and folder names match those specified above. All files and letters are case-sensitive.
- All zip files should be packed without compression.
