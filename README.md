ImageToMSFSKTX2

A batch file to convert image files to Microsoft Flight Simulator 2024 KTX2 files, with accompanying JSONs.

Instructions - setup

Copy the batch file to a folder of your choice. It doesn't matter where this batch file is located, it'll create the necessary folders relative to itself. You may want to add a copy to each livery project artwork folder.
You must have the Microsoft Flight Simulator 2024 SDK installed.
When you first run the batch file it will prompt you for the path to the MSFS 2024 SDK, for example C:\MSFS 2024 SDK. (Make sure you don't add a \ at the end of the path. I'll add some error checking to handle that soon.)
The batch file will also create four folders ALBD, COMP, NORM and DECAL.

Instructions - converting livery artwork to KTX2

1. Copy your PNG files in one of the folders ALBD (for albedo images), COMP (for composite images), DECAL (for decal images), NORM (for normal images). Note these folders will be auto-created by the batch file if it cannot find them.
2. From the command list, choose to generate the XML files for each image file. These XML files will be pre-populated with the right flags for each image type.
3. From the command list, choose to generate the KTX2 files. This command is only available once each of your image files has a corresponding XML file.
4. The script will launch the SDK and generate the KTX2 files. You should see a separate splash screen and console window. When these have disappeared press any key to finish. Your KTX2 and JSON files will be in a folder called OUTPUT, which is opened automatically in Windows Explorer.
5. Batch file activity is logged in logfile.txt
