# ImageToMSFSKTX2

A batch file to convert image files to Microsoft Flight Simulator 2024 KTX2 files, with accompanying JSONs. This is a script I've started out for my own use, but spent time adding new features, error handling and improving usability, to help out other livery creators converting images to the new KTX2 format.

## Instructions - setup

_For video instructions, check out my [tutorial video](https://youtu.be/rjGJcNRonWo?si=kaTt5Yoc2Cb6RDpE)._

1. From the [Releases](https://github.com/theflaknine/ImageToMSFSKTX2/releases) area of the [ImageToMSFSKTX2 repo](https://github.com/theflaknine/ImageToMSFSKTX2), download the latest release of my script and extract it.
2. Copy the batch file to a folder of your choice. It doesn't matter where this batch file is located, it'll create the necessary folders relative to itself. You may want to add a copy to each livery project artwork folder.
3. You must have the Microsoft Flight Simulator 2024 SDK installed.
4. When you first run the batch file it will prompt you for several settings:
   - the path to the MSFS 2024 SDK, for example, `C:\MSFS 2024 SDK`. It expects a path without a trailing backslash and will trim it off if you do add it
   - which version of MSFS 2024 are you running: either MICROSOFT or STEAM
   - the path to MSFSLayoutGenerator. This is optional but will allow you to automatically update the layout.json file of your livery after creating the KTX2 files; this functionality also requires you to set the TEXTURES folder as described below. Download MSFSLayoutGenerator [here](https://github.com/HughesMDflyer4/MSFSLayoutGenerator).
   - the path to the TEXTURES folder of your current livery project. This is optional but will allow you to generate the KTX2 files in the correct place, without needing to move or copy them afterwards. Ensure you include the full path to the folder where the texture files should end up.
      - the script contains logic to identify whether your livery project is for a MODULAR or NON-MODULAR MSFS 2024 aircraft, and will locate the layout.json file accordingly.
   - the QUALITYHIGH flag. If enabled (ON) this will instruct the MSFS 2024 SDK to use a higher quality compression; the tradeoff here is larger files which use more memory. Default state is ON. This is currently applicable to ALBEDO and DECAL textures only.
   - the ForceNoAlpha flag. If enabled (ON) this will remove the alpha channel from the resulting KTX2 file. Default state is OFF.
5. The batch file will also create four folders ALBD, COMP, NORM and DECAL. This is currently applicable to ALBEDO and DECAL textures only.

## Instructions - converting livery artwork to KTX2

1. Copy your PNG / TIF files in one of the folders ALBD (for albedo images), COMP (for composite images), DECAL (for decal images), NORM (for normal images). Note these folders will be auto-created by the batch file if it cannot find them.
   - IMPORTANT: Ensure the image file names are correct so they will be converted to correctly named KTX2 and JSON files. For example, `CUBV6_PRIMARYFUSELAGE_ALBD.PNG` will generate `CUBV6_PRIMARYFUSELAGE_ALBD.PNG.KTX2` and `CUBV6_PRIMARYFUSELAGE_ALBD.PNG.KTX2.JSON`.
2. From the command list, choose to generate the XML files for each image file. These XML files will be pre-populated with the right flags for each image type although you can edit them manually afterwards, before proceeding with the next step.
3. From the command list you have two methods of generating KTX2 files
   - Choose OPTION 4 to generate the KTX2 files in an OUTPUT sub-folder. This command is only available once each of your image files has a corresponding XML file.
   - Choose OPTION 5 to generate the KTX2 files in a designated aircraft livery texture folder. This command is only available once each of your iamge files has a corresponding XML file, AND you have specified valid locations for MSFSLayoutgenertor.exe and an aircraft livery texture folder.
6. The script will launch the SDK and generate the KTX2 files. You should see a separate splash screen and console window. When these have disappeared press any key to finish. The location of your files will depend whether you chose OPTION 4 or OPTION 5, but the folder will be opened automatically in Windows Explorer.
7. Batch file activity is comprehensively logged in logfile.txt

## What does the script do?

For each of your PNG / TIF files, the script:
1. Generates a [texture XML file](https://docs.flightsimulator.com/msfs2024/html/5_Content_Configuration/Textures/Texture_XML_Properties.htm) with suitable flags for Albedo, Composite, Normal or Decal image types (see below).
2. Sends the PNG / TIF and accompanying XML file to the Microsoft Flight Simulator 2024 SDK package builder, which compiles a KTX2 file and accompanying JSON file.
3. Copies the KTX2 and JSON file to the script's "OUTPUT" folder (when using OPTION 4) or a designated aircraft livery texture folder (when using OPTION 5).
4. Cleans up any temporary files

### Albedo textures
*Defines the base colour of your texture. If you are new to livery painting and aren't sure what type of texture you've created, it's most likely an albedo texture.*
- BitmapSlot String: MTL_BITMAP_DECAL0
- UserFlags: QUALITYHIGH (starting with v0.13, this flag can be modified in the settings page)
- ForceNoAlpha: FALSE (starting with v0.13, this flag can be modified in the settings page)

### Composite textures
*A composite image where the red channel defines ambient occlusion, green channel defines roughness, blue defines metallicness.*
- BitmapSlot String: MTL_BITMAP_METAL_ROUGH_AO
- UserFlags: QUALITYHIGH
- ForceNoAlpha: TRUE

### Normal textures
*Encodes surface normal directions using colour values, to simulate detailed textures without increasing the polygon count of the 3D model.*
- BitmapSlot String: MTL_BITMAP_NORMAL
- UserFlags: QUALITYHIGH
- ForceNoAlpha: FALSE

### Decal textures
*Used to apply details like labels and insignia on top of the base (albedo) texture. Currently, this uses the same flags as Albedo.*
- BitmapSlot String: MTL_BITMAP_DECAL0
- UserFlags: QUALITYHIGH (starting with v0.14, this flag can be modified in the settings page)
- ForceNoAlpha: FALSE (starting with v0.14, this flag can be modified in the settings page)

# Donations
This script is of course free, and there's no expectation for any donations whatsoever. However I have spent countless hours making this script as user-friendly as I can, so it can be shared with the community; so if you do want to offer a "thank you" via a small contribution to my [Buy Me A Coffee page](https://buymeacoffee.com/flaknine) then I'd be incredibly grateful!


 



