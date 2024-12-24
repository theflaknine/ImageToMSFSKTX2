echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
)
CLS
SET "log_file=%~dp0logfile.txt"
echo Started MSFS KTX2 version 0.4 > "%log_file%"
:MENU
set "settings_file=userConfig.ini"
if exist "%settings_file%" (
echo Found settings file %settings_file% >> "%log_file%"
for /f "delims=" %%i in (%settings_file%) do set "sdk_root=%%i"
echo Read MSFS SDK path as !sdk_root! >> "%log_file%"
) else (
echo Prompted user for MSFS SDK >> "%log_file%"
set /p new_path=Enter the path for the MSFS SDK, for example C:\MSFS 2024 SDK: 
echo User entered !new_path! >> "%log_file%"
set "last_char=!new_path:~-1!"
echo Last character is !last_char! >> "%log_file%"
if "!last_char!"=="\" (
echo Removing trailing backslash >> "%log_file%"
SET "new_path=!new_path:~0,-1!"
)
echo !new_path!>userConfig.ini
echo SDK path set to !new_path! >> "%log_file%"
set "sdk_root=!new_path!"
cls
)
SET countWithXML=0
SET countWithoutXML=0
SET totalCount=0
if not exist "%~dp0\ALBD" (
mkdir ALBD
echo Created ALBD folder >> "%log_file%"
) 
if not exist "%~dp0\COMP" (
mkdir COMP
echo Created COMP folder >> "%log_file%"
) 
if not exist "%~dp0\NORM" (
mkdir NORM
echo Created NORM folder >> "%log_file%"
)
if not exist "%~dp0\DECAL" (
mkdir DECAL
echo Created DECAL folder >> "%log_file%"
)
set "ALBD_dir=%~dp0ALBD"
echo ALBD dir is %ALBD_dir% >> "%log_file%"
set "COMP_dir=%~dp0COMP"
echo COMP dir is %COMP_dir% >> "%log_file%"
set "NORM_dir=%~dp0NORM"
echo NORM dir is %NORM_dir% >> "%log_file%"
set "DECAL_dir=%~dp0DECAL"
echo DECAL dir is %DECAL_dir% >> "%log_file%"
set albdCount=0
set compCount=0
set normCount=0
set decalCount=0
for %%f in ("%ALBD_dir%\*.png") do (set /a albdCount+=1)
echo Found !albdCount! albedo image files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (set /a compCount+=1)
echo Found !compCount! composite image files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (set /a normCount+=1)
echo Found !normCount! normal map image files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (set /a decalCount+=1)
for %%f in ("%DECAL_dir%\*.tif") do (set /a decalCount+=1)
echo Found !decalCount! decal image files >> "%log_file%"
echo Display list of files >> "%log_file%"
ECHO                         IMAGE TO MSFS KTX2 CONVERTER                       
ECHO ============================================================================
ECHO.
set count=0
if !albdCount! gtr 0 (
ECHO ----------------------------- ALBEDO PNG files -----------------------------
echo Checking albedo files >> "%log_file%"
)
FOR %%f in (".\ALBD\*.png") do (
set "filename=%%~nf"
echo ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = FAIL] %%f
set /a countWithoutXML+=1
)
)
if !compCount! gtr 0 (
ECHO.
ECHO --------------------------- COMPOSITE PNG files ----------------------------
echo Checking comp files >> "%log_file%"
)
FOR %%f in (".\COMP\*.png") do (
set "filename=%%~nf"
echo ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = FAIL] %%f
set /a countWithoutXML+=1
)
)
if !normCount! gtr 0 (
ECHO.
ECHO ---------------------------- NORMAL PNG files ------------------------------
echo Checking norm files >> "%log_file%"
)
FOR %%f in (".\NORM\*.png") do (
set "filename=%%~nf"
echo ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = FAIL] %%f
set /a countWithoutXML+=1
)
)
if !decalCount! gtr 0 (
ECHO.
ECHO ------------------------ DECAL TIF and PNG files ---------------------------
echo Checking decal files >> "%log_file%"
)
FOR %%f in (".\DECAL\*.png") do (
set "filename=%%~nf"
echo ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = FAIL] %%f
set /a countWithoutXML+=1
)
)
FOR %%f in (".\DECAL\*.tif") do (
set "filename=%%~nf"
echo ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = FAIL] %%f
set /a countWithoutXML+=1
)
)
set /a totalCount=countWithXML+countWithoutXML
ECHO.
ECHO --------------------------------- COMMANDS ---------------------------------
echo Display command list >> "%log_file%"
ECHO  1 - Update SDK path (%sdk_root%)
ECHO  2 - Generate missing XML files for !countWithoutXML! of !totalCount! image files
ECHO  3 - Regenerate XML files for all !totalCount! image files
if !countWithoutXML! gtr 0 (
ECHO  4 - Generate KTX2 files [COMMAND UNAVAILABLE]
) else (
ECHO  4 - Generate KTX2 files
)
ECHO  5 - Refresh
ECHO  6 - Exit
ECHO.
SET /P M=Choose an option then press ENTER: 
IF %M%==1 GOTO UPDATESDK
IF %M%==2 GOTO CREATEXMLS
IF %M%==3 GOTO RECREATEXMLS
IF %M%==4 GOTO CREATEKTX2
IF %M%==5 GOTO REFRESH
IF %M%==6 GOTO EOF
:UPDATESDK
echo User chose option 1 >> "%log_file%"
echo Deleting userConfig.ini >> "%log_file%"
del /q userConfig.ini
cls
goto MENU
:CREATEXMLS
echo User chose option 2 >> "%log_file%"
echo Creating missing XMLs for albedo files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo ...Creating XML file for %%~dpnf >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo Creating missing XMLs for composite files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo Creating missing XMLs for normal files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo Creating missing XMLs for decal PNG files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo ...Creating XML file for %%~dpff>> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo Creating missing XMLs for decal TIF files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.tif") do (
if not exist "%%~dpnf.xml" (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
cls
goto MENU
:RECREATEXMLS
echo User chose option 3 >> "%log_file%"
echo Recreating XMLs for albedo files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo Recreating XMLs for composite files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo Recreating XMLs for normal files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo Recreating XMLs for decal files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
echo ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
for %%f in ("%DECAL_dir%\*.tif") do (
echo ...5Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
cls
goto MENU
:CREATEKTX2
echo User chose option 4 >> "%log_file%"
cls
if not exist "%sdk_root%\tools\bin\fspackagetool.exe" (
ECHO Unable to create KTX2 files because "%sdk_root%\tools\bin\fspackagetool.exe" could not be found. Check the specified path in the menu of this batch file.
echo Could not find "%sdk_root%\tools\bin\fspackagetool.exe" >> "%log_file%"
pause >nul
cls
goto MENU
) else (
echo Found "%sdk_root%\tools\bin\fspackagetool.exe" >> "%log_file%"
)
if !countWithoutXML! gtr 0 (
ECHO Unable to create KTX2 files because there are !countWithoutXML! missing XML files. Press any key to continue...
ECHO Unable to create KTX2 files because there are !countWithoutXML! missing XML files. >> "%log_file%"
pause >nul
cls
goto MENU
)
rem Make directory structure
if not exist "PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture" (
echo Folder didn't exist so creating PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture >> "%log_file%"
mkdir PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture
)
if not exist "PackageDefinitions" (
echo Folder didn't exist so creating PackageDefinitions >> "%log_file%"
mkdir PackageDefinitions
)
rem Create package definition xml - UPDATE THIS TO AVOID CHANGE DIR
echo Change Dir to PackageDefinitions >> "%log_file%"
cd PackageDefinitions
echo Change Dir to PackageDefinitions then create definition XML png-2-ktx2.xml >> "%log_file%"
echo ^<?xml version="1.0" encoding="utf-8"?^>^<AssetPackage Version="0.1.0"^>^<ItemSettings^>^<ContentType^>AIRCRAFT^</ContentType^>^<Title^>PNG TO KTX2 CONVERTER^</Title^>^<Manufacturer^>FlakNine^</Manufacturer^>^<Creator^>FlakNine^</Creator^>^</ItemSettings^>^<Flags^>^<VisibleInStore^>true^</VisibleInStore^>^<CanBeReferenced^>true^</CanBeReferenced^>^</Flags^>^<AssetGroups^>^<AssetGroup Name="PNG TO KTX2 CONVERTER"^>^<Type^>ModularSimObject^</Type^>^<Flags^>^<FSXCompatibility^>false^</FSXCompatibility^>^</Flags^>^<AssetDir^>PackageSources\SimObjects\Airplanes\png-2-ktx2\^</AssetDir^>^<OutputDir^>SimObjects\Airplanes\png-2-ktx2\^</OutputDir^>^</AssetGroup^>^</AssetGroups^>^</AssetPackage^> > png-2-ktx2.xml
echo Change Dir to parent >> "%log_file%"
cd.. 
rem Create project xml
echo Create project XML png-2-ktx2.xml >> "%log_file%"
echo ^<?xml version="1.0" encoding="utf-8"?^>^<Project Version="2" Name="PNG TO KTX2 CONVERTER" FolderName="Packages" MetadataFolderName="PackagesMetadata"^>^<OutputDirectory^>.^</OutputDirectory^>^<TemporaryOutputDirectory^>_PackageInt^</TemporaryOutputDirectory^>^<Packages^>^<Package^>PackageDefinitions\png-2-ktx2.xml^</Package^>^</Packages^>^</Project^> > png-2-ktx2.xml
rem Copy Albedo PNG and XML files
echo For each PNG in !ALBD_dir!... >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Copy Composite PNG and XML files
echo For each PNG in !COMP_dir!... >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo ...Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Normal PNG and XML files
echo For each PNG in !NORM_dir!... >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo ...Copy "%%~dpnf.png" to "..\PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Decal PNG TIF and XML files
echo For each PNG in !DECAL_dir!... >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo ...Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
echo For each TIF in !DECAL_dir!... >> "%log_file%"
for %%f in ("%DECAL_dir%\*.tif") do (
if exist "%%~dpnf.tif" (
echo ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo ...Copy "%%~dpnf.tif" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.tif" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
ECHO Step 1 of 3: Launching standalone Flight Simulator package tool... 
echo Step 1 of 3: Launching standalone Flight Simulator package tool...  >> "%log_file%"
"%sdk_root%\tools\bin\fspackagetool.exe" -nopause -outputtoseparateconsole "png-2-ktx2.xml"
cls
echo Step 2 of 3: Generating KTX2 files...
echo Step 2 of 3: Generating KTX2 files...  >> "%log_file%"
:CHECK_PROCESS
tasklist /FI "IMAGENAME eq FlightSimulator2024.exe" 2>NUL | find /I /N "FlightSimulator2024.exe">NUL
if "%ERRORLEVEL%"=="0" (
    timeout /T 5 /NOBREAK >NUL
    goto CHECK_PROCESS
)
cls
echo Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files and finish.
echo Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files and finish.  >> "%log_file%"
color 2f
pause >nul
if not exist "OUTPUT" (mkdir OUTPUT)
xcopy .\Packages\png-2-ktx2\SimObjects\Airplanes\png-2-ktx2\common\texture\*.* .\OUTPUT\ /s /e /y /I
echo Delete temporary folders >> "%log_file%"
rmdir /s /q "_PackageInt"
rmdir /s /q "PackageDefinitions"
rmdir /s /q "PackagesMetadata"
rmdir /s /q "PackageSources"
rmdir /s /q "Packages"
echo Delete project file png-2-ktx2.xml  >> "%log_file%"
del /q png-2-ktx2.xml 
echo Open the new folder OUTPUT >> "%log_file%"
start "" ".\OUTPUT"
echo End of script >> "%log_file%"
goto EOF
:REFRESH
CLS
echo Refresh menu >> "%log_file%"
goto MENU
