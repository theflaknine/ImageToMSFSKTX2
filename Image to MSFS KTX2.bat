echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
)
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
echo %ESC%[0;32mGREEN%ESC%[0m
echo %ESC%[0;93mYELLOW%ESC%[0m
echo %ESC%[0;91mRED%ESC%[0m


for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
    set "ESC=%%a"
)
CLS
SET "log_file=%~dp0logfile.txt"
SET "AppVersion=0.10"
SET "SimType=UNDEFINED"
echo %DATE% %TIME% Started Image to MSFS KTX2 version %AppVersion% > "%log_file%"
:MENU
set "settings_file=userConfig.ini"
if not exist "%settings_file%" (
	ECHO Your Image to MSFS KTX2 settings are not defined yet. Press any key to go to the settings page...
	PAUSE >nul
	rem Cannot find setting file, prompt user for settings by sending them to the configuration menu
	SET "sdk_root=UNDEFINED"
	SET "sdkVer=UNDEFINED"
	SET "LG_path=UNDEFINED"
	SET "Tex_path=UNDEFINED"
	GOTO CONFIGMENU
	) else (
	GOTO READSETTINGS
)

:SDKPATHMENU
cls
echo %DATE% %TIME% Prompted user for MSFS SDK >> "%log_file%"
set /p sdk_root=Enter the path for the MSFS SDK, for example C:\MSFS 2024 SDK: 
echo %DATE% %TIME% User entered !sdk_root! >> "%log_file%"
set "last_char=!sdk_root:~-1!"
echo %DATE% %TIME% Last character is 0!last_char! >> "%log_file%"
if "!last_char!"=="\" (
	echo %DATE% %TIME% Removing trailing backslash >> "%log_file%"
	SET "sdk_root=!sdk_root:~0,-1!"
)

rem Get SDK version from version.txt file
if exist "%sdk_root%\version.txt" (
	set /p sdkVer=<!sdk_root!\version.txt
	echo %DATE% %TIME% MSFS SDK version: !sdkVer! >> "%log_file%"
) else (
	set sdkVer=Unknown
)
call :WRITESETTINGS
Goto CONFIGMENU

:SIMTYPEMENU
cls
SET /p choice=Define which version of Microsoft Flight Simulator 2024 you are using: 1 = MICROSOFT; 2 = STEAM; then press ENTER:
IF %choice%==1 (
	set "simType=MICROSOFT"
) else if %choice%==2 (
	set "simType=STEAM"
) else (
echo Invalid value, try again
goto SIMTYPEMENU
)
echo %DATE% %TIME% Found settings file %settings_file% >> "%log_file%"
call :WRITESETTINGS
Goto CONFIGMENU


:LAYOUTGEN
rem Prompt user for path to MSFSLayoutgen.exe
echo %DATE% %TIME% Prompted user for path to MSFSLayoutGenerator.exe >> "%log_file%"
cls
echo Optionally enter the path to the MSFSLayoutGenerator.exe, for example G:\MSFSLayoutGenerator
set /p LG_path=Path:
echo %DATE% %TIME% User entered !LG_path! >> "%log_file%"
set "last_char=!LG_path:~-1!"
echo %DATE% %TIME% Last character is 0!last_char! >> "%log_file%"
if "!last_char!"=="\" (
	echo %DATE% %TIME% Removing trailing backslash >> "%log_file%"
	SET "LG_path=!LG_path:~0,-1!"
)
call :WRITESETTINGS
Goto CONFIGMENU

:LIVERYTEX 
echo %DATE% %TIME% Prompted user for path to Aircraft TEXTURE folder >> "%log_file%"
cls
echo Enter the path for the Aircraft TEXTURE folder, e.g. G:\MyAircraft\SimObjects\Airplanes\MyAircraft\texture.myAircraft.
set /p Tex_path=Path: 
echo %DATE% %TIME% User entered !Tex_path! >> "%log_file%"
set "last_char=!Tex_path:~-1!"
echo %DATE% %TIME% Last character is 0!last_char! >> "%log_file%"
if "!last_char!"=="\" (
	echo %DATE% %TIME% Removing trailing backslash >> "%log_file%"
	SET "Tex_path=!Tex_path:~0,-1!"
)
set "layoutPath=!Tex_path!\..\..\..\..\layout.json"
set "manifestPath=!Tex_path!\..\..\..\..\manifest.json"
if exist !manifestPath! (
			echo Found manifest.json OK
				set "searchKey="title""
				for /f "delims=" %%a in ('type "!manifestPath!" ^| findstr /c:"\"title\""') do (
				set "line=%%a"
				for /f "tokens=2 delims=:" %%b in ("!line!") do (
				set "LiveryTitle=%%b"
				)
				)
				rem  Remove leading and trailing spaces, quotes, and commas
				if "!LiveryTitle:~-1!"=="," (
				set "LiveryTitle=!LiveryTitle:~0,-1!"
				)
				echo Successfully found the livery titled: !LiveryTitle!
			Pause
			)
call :WRITESETTINGS
Goto CONFIGMENU

:WRITESETTINGS
rem Write variables to settings files
echo %DATE% %TIME% Updating the settings file >> "%log_file%"
(
echo AppVersion=%AppVersion%
echo SimType=%simType%
echo sdk_root=!sdk_root!
echo LG_path=!LG_path!
echo Tex_path=!Tex_path!
)>userConfig.ini 
Exit /B


:READSETTINGS
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
rem Read first line of the settings file
set /p firstLine=<%settings_file%
echo %firstLine% | findstr /b /c:"AppVersion" >nul
	if %errorlevel%==0 (
		rem Settings file starts with AppVersion
		set isAppVersion=true
		echo %DATE% %TIME% The settings file %settings_file% has the correct format>> "%log_file%"
	) else (
		rem Settings file does not start with AppVersion
		set isAppVersion=false
		echo %DATE% %TIME% The settings file %settings_file% has the incorrect format and will be deleted>> "%log_file%"
		echo The UserConfig.ini settings file for IMAGE TO MSFS KTX2 was created before v0.8 and will be deleted. 
		echo You will need to enter your settings again. Press any key to proceed.
		Pause
		del /f /q "UserConfig.ini"
		CLS
		GOTO MENU
	)
	
rem Read the settings from the file
for /f "tokens=1,2 delims==" %%A in (%settings_file%) do (set "%%A=%%B")

rem Write the settings to the log file
echo %DATE% %TIME% AppVersion is %AppVersion% >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: SimType is %SimType% >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: sdk_root is %sdk_root% >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: lg_path is !lg_path! >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: tex_path is !tex_path! >> "%log_file%"


rem ) else (

rem echo !new_path!>userConfig.ini
rem echo %DATE% %TIME% SDK path set to !new_path! >> "%log_file%"
rem set "sdk_root=!new_path!"

if exist "!sdk_root!\version.txt" (
set /p sdkVer=<!sdk_root!\version.txt
echo %DATE% %TIME% MSFS SDK version: !sdkVer! >> "%log_file%"
) else (
set sdkVer=Unknown
)
cls
)

SET countWithXML=0
SET countWithoutXML=0
SET totalCount=0
if not exist "%~dp0\ALBD" (
mkdir ALBD
echo %DATE% %TIME% Created ALBD folder >> "%log_file%"
) 
if not exist "%~dp0\COMP" (
mkdir COMP
echo %DATE% %TIME% Created COMP folder >> "%log_file%"
) 
if not exist "%~dp0\NORM" (
mkdir NORM
echo %DATE% %TIME% Created NORM folder >> "%log_file%"
)
if not exist "%~dp0\DECAL" (
mkdir DECAL
echo %DATE% %TIME% Created DECAL folder >> "%log_file%"
)
set "ALBD_dir=%~dp0ALBD"
echo %DATE% %TIME% ALBD dir is %ALBD_dir% >> "%log_file%"
set "COMP_dir=%~dp0COMP"
echo %DATE% %TIME% COMP dir is %COMP_dir% >> "%log_file%"
set "NORM_dir=%~dp0NORM"
echo %DATE% %TIME% NORM dir is %NORM_dir% >> "%log_file%"
set "DECAL_dir=%~dp0DECAL"
echo %DATE% %TIME% DECAL dir is %DECAL_dir% >> "%log_file%"
set albdCount=0
set compCount=0
set normCount=0
set decalCount=0
for %%f in ("%ALBD_dir%\*.png") do (set /a albdCount+=1)
echo %DATE% %TIME% Found !albdCount! albedo image files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (set /a compCount+=1)
echo %DATE% %TIME% Found !compCount! composite image files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (set /a normCount+=1)
echo %DATE% %TIME% Found !normCount! normal map image files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (set /a decalCount+=1)
for %%f in ("%DECAL_dir%\*.tif") do (set /a decalCount+=1)
echo %DATE% %TIME% Found !decalCount! decal image files >> "%log_file%"
echo %DATE% %TIME% Display list of files >> "%log_file%"
ECHO                    IMAGE TO MSFS KTX2 CONVERTER v%AppVersion%                      
ECHO ============================================================================
ECHO.
set count=0
if !albdCount! gtr 0 (
ECHO ----------------------------- ALBEDO PNG files -----------------------------
echo %DATE% %TIME% Checking albedo files >> "%log_file%"
) else (
ECHO ----------------------------- ALBEDO PNG files -----------------------------
echo None found in %ALBD_dir%
echo.
)
FOR %%f in (".\ALBD\*.png") do (
set "filename=%%~nf"
echo %DATE% %TIME% ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo %DATE% %TIME% ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo %DATE% %TIME% ......No matching XML for %%~ff  >> "%log_file%"
rem echo %ESC%[0;91mRED%ESC%[0m
ECHO [Has XML = %ESC%[0;91mFAIL%ESC%[0m] %%f
set /a countWithoutXML+=1
)
)
if !compCount! gtr 0 (
ECHO.
ECHO --------------------------- COMPOSITE PNG files ----------------------------
echo %DATE% %TIME% Checking comp files >> "%log_file%"
) else (
ECHO --------------------------- COMPOSITE PNG files ----------------------------
echo None found in %COMP_dir%
echo.
)
FOR %%f in (".\COMP\*.png") do (
set "filename=%%~nf"
echo %DATE% %TIME% ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo %DATE% %TIME% ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo %DATE% %TIME% ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = %ESC%[0;91mFAIL%ESC%[0m] %%f
set /a countWithoutXML+=1
)
)
if !normCount! gtr 0 (
ECHO.
ECHO ---------------------------- NORMAL PNG files ------------------------------
echo %DATE% %TIME% Checking norm files >> "%log_file%"
) else (
ECHO ---------------------------- NORMAL PNG files ------------------------------
echo None found in %NORM_dir%
echo.
)
FOR %%f in (".\NORM\*.png") do (
set "filename=%%~nf"
echo %DATE% %TIME% ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo %DATE% %TIME% ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo %DATE% %TIME% ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = %ESC%[0;91mFAIL%ESC%[0m] %%f
set /a countWithoutXML+=1
)
)
if !decalCount! gtr 0 (
ECHO.
ECHO ------------------------ DECAL TIF and PNG files ---------------------------
echo %DATE% %TIME% Checking decal files >> "%log_file%"
) else (
ECHO ------------------------ DECAL TIF and PNG files ---------------------------
echo None found in %DECAL_dir%
echo.
)
FOR %%f in (".\DECAL\*.png") do (
set "filename=%%~nf"
echo %DATE% %TIME% ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo %DATE% %TIME% ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo %DATE% %TIME% ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = %ESC%[0;91mFAIL%ESC%[0m] %%f
set /a countWithoutXML+=1
)
)
FOR %%f in (".\DECAL\*.tif") do (
set "filename=%%~nf"
echo %DATE% %TIME% ...Checking for matching XML for %%~ff  >> "%log_file%"
if exist "%%~ff.xml" (
echo %DATE% %TIME% ......Found matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = OK]   %%f
set /a countWithXML+=1
) else (
echo %DATE% %TIME% ......No matching XML for %%~ff  >> "%log_file%"
ECHO [Has XML = %ESC%[0;91mFAIL%ESC%[0m] %%f
set /a countWithoutXML+=1
)
)
set /a totalCount=countWithXML+countWithoutXML
call :CHECK5 !countWithoutXML!
ECHO.
ECHO --------------------------------- COMMANDS  ---------------------------------
echo %DATE% %TIME% Display command list >> "%log_file%"
ECHO  1 - Edit Settings 
ECHO  2 - Generate missing XML files for !countWithoutXML! of !totalCount! image files
ECHO  3 - Regenerate XML files for all !totalCount! image files
if !countWithoutXML! gtr 0 (
ECHO  %ESC%[0;90m4 - Generate KTX2 files in the OUTPUT folder [COMMAND UNAVAILABLE]%ESC%[0m
) else (
ECHO  4 - Generate KTX2 files in the OUTPUT folder
)
if %EnableOption5%==true (
ECHO  5 - Generate KTX2 files in aircraft texture folder and run MSFSLayoutGenerator.exe
) else (
ECHO  %ESC%[0;90m5 - Generate KTX2 files in aircraft texture folder and run MSFSLayoutGenerator.exe [COMMAND UNAVAILABLE]%ESC%[0m
)
ECHO  6 - Refresh
ECHO  7 - Exit
ECHO.
SET /P M=Choose an option then press ENTER: 
IF %M%==1 GOTO CONFIGMENU
IF %M%==2 GOTO CREATEXMLS
IF %M%==3 GOTO RECREATEXMLS
IF %M%==4 GOTO CREATEKTX2
IF %M%==5 (
if %EnableOption5%==true (
GOTO CREATEKTX2
)
)
IF %M%==6 GOTO REFRESH
IF %M%==7 GOTO EOF
rem User input a different value, try again!
CLS
goto MENU
:CONFIGMENU
ECHO --------------------------------- CONFIGURATION ---------------------------------
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
echo %DATE% %TIME% Display configuration menu list >> "%log_file%"
CLS
ECHO  1: Edit SDK path
ECHO  %ESC%[0;93m%sdk_root% %ESC%[0m
ECHO  SDK version detected as: %ESC%[0;93m%sdkVer% %ESC%[0m
ECHO.
ECHO  2: Change MSFS 2024 version
ECHO  %ESC%[0;93m%simType% %ESC%[0m
ECHO.
ECHO  3: Edit MSFSLayoutGenerator path (Optional: updates the layout.json file of an existing livery project)
ECHO  %ESC%[0;93m%LG_path% %ESC%[0m
ECHO.
ECHO  4: Edit Livery texture path (Optional: output the KTX2 files directly to an existing livery project)
ECHO  %ESC%[0;93m%Tex_path% %ESC%[0m
ECHO.
ECHO  5: Go back to main menu
ECHO.
SET /P S=Choose an option then press ENTER: 
IF %S%==1 GOTO SDKPATHMENU
IF %S%==2 GOTO SIMTYPEMENU
IF %S%==3 GOTO LAYOUTGEN
IF %S%==4 GOTO LIVERYTEX
IF %S%==5 GOTO MENU
rem User input a different value, try again!
CLS
goto CONFIGMENU


:CREATEXMLS
echo %DATE% %TIME% User chose option 2 >> "%log_file%"
echo %DATE% %TIME% Creating missing XMLs for albedo files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpnf >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for composite files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for normal files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for decal PNG files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff>> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for decal TIF files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.tif") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
cls
goto MENU
:RECREATEXMLS
echo %DATE% %TIME% User chose option 3 >> "%log_file%"
echo %DATE% %TIME% Recreating XMLs for albedo files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for composite files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for normal files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for decal files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
for %%f in ("%DECAL_dir%\*.tif") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
cls
goto MENU

:CHECK5
rem Check if "%LG_path%\MSFSLayoutGenerator.exe" exists
set inputValue=%1
echo %DATE% %TIME% Check if "%LG_path%\MSFSLayoutGenerator.exe" exists >> "%log_file%"
if exist "%LG_path%\MSFSLayoutGenerator.exe" (
	echo %DATE% %TIME% "%LG_path%\MSFSLayoutGenerator.exe" found OK >> "%log_file%"
	rem Check if !tex_path! exists
	if exist !Tex_path! (
		echo %DATE% %TIME% "!Tex_path!" found OK >> "%log_file%"
		rem Check count without XML
		if %inputValue%==0 (
			echo %DATE% %TIME% Option 5 can be enabled >> "%log_file%"
			set "EnableOption5=true"
		) else (
		echo %DATE% %TIME% !countWithouXML! files without XML, disable option 5 >> "%log_file%"
		set "EnableOption5=false"
		)
	) else (
		echo %DATE% %TIME% "!Tex_path!" not found, disable option 5 >> "%log_file%"
		set "EnableOption5=false"
	)
) else (
echo %DATE% %TIME% "%LG_path%\MSFSLayoutGenerator.exe" not found, disable option 5 >> "%log_file%"
set "EnableOption5=false"
)
exit /B

:CREATEKTX2
cls
IF !M!==5 (
	echo %DATE% %TIME% User chose option 5 >> "%log_file%"
	echo %DATE% %TIME% Check if "%LG_path%\MSFSLayoutGenerator.exe" exists >> "%log_file%"
		if exist "%LG_path%\MSFSLayoutGenerator.exe" (
		echo %DATE% %TIME% "%LG_path%\MSFSLayoutGenerator.exe" found OK >> "%log_file%"
			rem Find and read manifest.json 
			set "layoutPath=!Tex_path!\..\..\..\..\layout.json"
			set "manifestPath=!Tex_path!\..\..\..\..\manifest.json"
			echo %DATE% %TIME% Layout path: !layoutPath! >> "%log_file%"
			echo %DATE% %TIME% Manifest path: !manifestPath! >> "%log_file%"
			if exist !layoutPath! (
			echo Found layout.json OK
			) else (
			echo Could not find layout.json, press any key to return to menu
			pause >nul
			goto MENU
			)
			if exist !manifestPath! (
			echo Found manifest.json OK
				set "searchKey="title""
				for /f "delims=" %%a in ('type "!manifestPath!" ^| findstr /c:"\"title\""') do (
				set "line=%%a"
				for /f "tokens=2 delims=:" %%b in ("!line!") do (
				set "value=%%b"
				)
				)
				rem  Remove leading and trailing spaces, quotes, and commas
				if "!value:~-1!"=="," (
				set "value=!value:~0,-1!"
				)
				echo Successfully found the livery titled: !value!
				echo Found %LG_path%\MSFSLayoutGenerator.exe OK.
			Pause
			) else (
			echo Could not find manifest.json, press any key to return to menu
			pause >nul
			goto MENU
			
			)
		) else (
		echo %DATE% %TIME% "%LG_path%\MSFSLayoutGenerator.exe" not found >> "%log_file%"
		ECHO Could not find MSFSLayoutGenerator.exe at %LG_path%. Check the specified path in the configuration menu.
		goto MENU
		)
	) else (
	echo %DATE% %TIME% User chose option 4 >> "%log_file%"
)
cls
if not exist "%sdk_root%\tools\bin\fspackagetool.exe" (
ECHO Unable to create KTX2 files because "%sdk_root%\tools\bin\fspackagetool.exe" could not be found. Check the specified path in the configuration menu.
echo %DATE% %TIME% Could not find "%sdk_root%\tools\bin\fspackagetool.exe" >> "%log_file%"
pause >nul
cls
goto MENU
) else (
echo %DATE% %TIME% Found "%sdk_root%\tools\bin\fspackagetool.exe" >> "%log_file%"
)
if !countWithoutXML! gtr 0 (
ECHO Unable to create KTX2 files because there are !countWithoutXML! missing XML files. Press any key to continue...
ECHO %DATE% %TIME% Unable to create KTX2 files because there are !countWithoutXML! missing XML files. >> "%log_file%"
pause >nul
cls
goto MENU
)
rem Make directory structure
if not exist "%~dp0\PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture" (
echo %DATE% %TIME% Folder didn't exist so creating PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture >> "%log_file%"
mkdir "%~dp0\PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture"
)
if not exist "%~dp0\PackageDefinitions" (
echo %DATE% %TIME% Folder didn't exist so creating PackageDefinitions >> "%log_file%"
mkdir "%~dp0\PackageDefinitions"
)
rem Create package definition xml
echo %DATE% %TIME% Create Package Definition XML png-2-ktx2.xml in PackageDefinitions folder >> "%log_file%"
echo ^<?xml version="1.0" encoding="utf-8"?^>^<AssetPackage Version="0.1.0"^>^<ItemSettings^>^<ContentType^>AIRCRAFT^</ContentType^>^<Title^>PNG TO KTX2 CONVERTER^</Title^>^<Manufacturer^>FlakNine^</Manufacturer^>^<Creator^>FlakNine^</Creator^>^</ItemSettings^>^<Flags^>^<VisibleInStore^>true^</VisibleInStore^>^<CanBeReferenced^>true^</CanBeReferenced^>^</Flags^>^<AssetGroups^>^<AssetGroup Name="PNG TO KTX2 CONVERTER"^>^<Type^>ModularSimObject^</Type^>^<Flags^>^<FSXCompatibility^>false^</FSXCompatibility^>^</Flags^>^<AssetDir^>PackageSources\SimObjects\Airplanes\png-2-ktx2\^</AssetDir^>^<OutputDir^>SimObjects\Airplanes\png-2-ktx2\^</OutputDir^>^</AssetGroup^>^</AssetGroups^>^</AssetPackage^> > "%~dp0\PackageDefinitions\png-2-ktx2.xml"
echo %DATE% %TIME% Create project XML png-2-ktx2.xml >> "%log_file%"
echo ^<?xml version="1.0" encoding="utf-8"?^>^<Project Version="2" Name="PNG TO KTX2 CONVERTER" FolderName="Packages" MetadataFolderName="PackagesMetadata"^>^<OutputDirectory^>.^</OutputDirectory^>^<TemporaryOutputDirectory^>_PackageInt^</TemporaryOutputDirectory^>^<Packages^>^<Package^>PackageDefinitions\png-2-ktx2.xml^</Package^>^</Packages^>^</Project^> > "%~dp0\png-2-ktx2.xml"
rem Copy Albedo PNG and XML files
echo %DATE% %TIME% For each PNG in !ALBD_dir!... >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Copy Composite PNG and XML files
echo %DATE% %TIME% For each PNG in !COMP_dir!... >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Normal PNG and XML files
echo %DATE% %TIME% For each PNG in !NORM_dir!... >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.png" to "..\PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Decal PNG TIF and XML files
echo %DATE% %TIME% For each PNG in !DECAL_dir!... >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
echo %DATE% %TIME% For each TIF in !DECAL_dir!... >> "%log_file%"
for %%f in ("%DECAL_dir%\*.tif") do (
if exist "%%~dpnf.tif" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.tif" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.tif" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
ECHO Step 1 of 3: Launching standalone Flight Simulator package tool... 
echo %DATE% %TIME% Step 1 of 3: Launching standalone Flight Simulator package tool...  >> "%log_file%"
ECHO Sim type: %simType%
ECHO Project file: %~dp0png-2-ktx2.xml
rem RUNNING THE FSPACKAGETOOL.EXE
echo %DATE% %TIME% Using sim type of: %simType% >> "%log_file%"
if %SimType%==STEAM (
rem Use the -forcesteam parameter (Steam version of sim)
echo %DATE% %TIME% Command sent: "%sdk_root%\tools\bin\fspackagetool.exe" -nopause -forcesteam -outputtoseparateconsole "%~dp0png-2-ktx2.xml" >> "%log_file%"
rem pause
"%sdk_root%\tools\bin\fspackagetool.exe" -nopause -forcesteam -outputtoseparateconsole "%~dp0png-2-ktx2.xml"
) else ( 
rem Do not use the -forcesteam parameter (Microsoft version of sim)
echo %DATE% %TIME% Command sent: "%sdk_root%\tools\bin\fspackagetool.exe" -nopause -outputtoseparateconsole "%~dp0png-2-ktx2.xml" >> "%log_file%"
rem pause
"%sdk_root%\tools\bin\fspackagetool.exe" -nopause -outputtoseparateconsole "%~dp0png-2-ktx2.xml"
)
cls
echo Step 2 of 3: Generating KTX2 files...
echo %DATE% %TIME% Step 2 of 3: Generating KTX2 files...  >> "%log_file%"
:CHECK_PROCESS
echo %DATE% %TIME% Checking if process name FlightSimulator2024.exe has closed yet... >> "%log_file%"
tasklist /FI "IMAGENAME eq FlightSimulator2024.exe" 2>NUL | find /I /N "FlightSimulator2024.exe">NUL
if "%ERRORLEVEL%"=="0" (
    timeout /T 5 /NOBREAK >NUL
    goto CHECK_PROCESS
)
cls
IF !M!==5 (
echo Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files, update the livery layout.json and finish.
echo %DATE% %TIME% Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files and finish.  >> "%log_file%"
color 2f
) else (
echo Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files and finish.
echo %DATE% %TIME% Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files and finish.  >> "%log_file%"
color 2f
)
pause >nul
rem Check whether user ran option 4 or 5
IF !M!==5 (
rem placeholder for setting output path to Tex_path
set OutputPath=!Tex_path!
) else (
rem placeholder for setting output path to "%~dp0OUTPUT"
set OutputPath="%~dp0OUTPUT"
)
rem echo %OutputPath%
echo %DATE% %TIME% Creating folder if it doesn't exist: "%OutputPath%" >> "%log_file%"
if not exist "%OutputPath%" (mkdir "%OutputPath%")
echo %DATE% %TIME% Run XCOPY command >> "%log_file%"
xcopy "%~dp0Packages\png-2-ktx2\SimObjects\Airplanes\png-2-ktx2\common\texture\*.*" "%OutputPath%"  /s /e /y /i
echo %DATE% %TIME% Delete temporary folders >> "%log_file%"
rmdir /s /q "_PackageInt"
rmdir /s /q "PackageDefinitions"
rmdir /s /q "PackagesMetadata"
rmdir /s /q "PackageSources"
rmdir /s /q "Packages"
echo %DATE% %TIME% Delete project file png-2-ktx2.xml  >> "%log_file%"
del /q png-2-ktx2.xml 
IF !M!==5 (
echo Ready to run MSFSLayoutGenerator
echo %DATE% %TIME% Run MSFSLayoutGenerator.exe on "%layoutPath%" >> "%log_file%"
echo %DATE% %TIME% Command: "%LG_path%\MSFSLayoutGenerator.exe" "%layoutPath%" >> "%log_file%"
rem run MSFSLayoutGenerator.exe
"%LG_path%\MSFSLayoutGenerator.exe" "%layoutPath%"
set OutputPath=!Tex_path!
) 
echo %DATE% %TIME% Open the the folder "%OutputPath%" >> "%log_file%"
start "" "%OutputPath%"
echo %DATE% %TIME% End of script >> "%log_file%"
goto EOF
:REFRESH
CLS
echo %DATE% %TIME% Refresh menu >> "%log_file%"
goto MENU
