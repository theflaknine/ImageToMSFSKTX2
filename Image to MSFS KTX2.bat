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
SET "CurrentAppVersion=0.14"
SET "AppVersion=%CurrentAppVersion%"
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
	SET "HQ_Flag_Albd=ON"
	SET "NoAlpha_Flag_Albd=OFF"
	SET "HQ_Flag_Decal=ON"
	SET "NoAlpha_Flag_Decal=OFF"
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

:HQFLAGTOGGLEALBD
rem Toggle High Quality Flag on or off for ALBEDO
echo %DATE% %TIME% Toggling ALBEDO HQ flag >> "%log_file%"
if "!HQ_Flag_Albd!"=="ON" (
set "HQ_Flag_Albd=OFF"
) else (
set "HQ_Flag_Albd=ON"
)
call :WRITESETTINGS
Goto CONFIGMENU

:NOALPHAFLAGTOGGLEALBD
rem Toggle High Quality Flag on or off for ALBEDO
echo %DATE% %TIME% Toggling ALBEDO No Alpha flag >> "%log_file%"
if "!NoAlpha_Flag_Albd!"=="ON" (
set "NoAlpha_Flag_Albd=OFF"
) else (
set "NoAlpha_Flag_Albd=ON"
)
call :WRITESETTINGS
Goto CONFIGMENU

:HQFLAGTOGGLEDECAL
rem Toggle High Quality Flag on or off for DECAL
echo %DATE% %TIME% Toggling DECAL HQ flag >> "%log_file%"
if "!HQ_Flag_Decal!"=="ON" (
set "HQ_Flag_Decal=OFF"
) else (
set "HQ_Flag_Decal=ON"
)
call :WRITESETTINGS
Goto CONFIGMENU

:NOALPHAFLAGTOGGLEDECAL
rem Toggle High Quality Flag on or off for DECAL
echo %DATE% %TIME% Toggling DECAL No Alpha flag >> "%log_file%"
if "!NoAlpha_Flag_Decal!"=="ON" (
set "NoAlpha_Flag_Decal=OFF"
) else (
set "NoAlpha_Flag_Decal=ON"
)
call :WRITESETTINGS
Goto CONFIGMENU




:LIVERYTEX 
echo %DATE% %TIME% Prompted user for path to Aircraft TEXTURE folder >> "%log_file%"
cls
echo Enter the path for the Aircraft TEXTURE folder, e.g. G:\MyAircraft\SimObjects\Airplanes\MyAircraft\texture.myAircraft.
echo IMPORTANT: The path length plus the filenames of the texture files must not exceed 256 characters^^!
set /p Tex_path=Path: 
echo %DATE% %TIME% User entered !Tex_path! >> "%log_file%"
set "last_char=!Tex_path:~-1!"
echo %DATE% %TIME% Last character is !last_char! >> "%log_file%"
if "!last_char!"=="\" (
	echo %DATE% %TIME% Removing trailing backslash >> "%log_file%"
	SET "Tex_path=!Tex_path:~0,-1!"
)
CLS
rem Attempt to find layout.json
call :READLAYOUT
rem Read title from manifest.json
CALL :READMANIFEST	
pause	
rem Write to settings file
call :WRITESETTINGS
Goto CONFIGMENU



:READLAYOUT
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
echo Aircraft texture path:%ESC%[0;93m !Tex_path! %ESC%[0m
echo %DATE% %TIME% Started function READLAYOUT >> "%log_file%"
echo %DATE% %TIME% Check if layout.json can be found in either expected location >> "%log_file%"
if exist !Tex_path!\..\..\..\..\layout.json (
	set "layoutPath=!Tex_path!\..\..\..\..\layout.json"
	rem Convert layoutpath from relative to absolute path
	CALL :NORMALIZEPATH "!layoutPath!"
	set "layoutpath=!retval!"
	echo %DATE% %TIME% !layoutPath! exists, this is a non-modular MSFS 2024 aircraft  >> "%log_file%"
	echo Found:%ESC%[0;93m !layoutPath! %ESC%[0m
	set "manifestPath=!Tex_path!\..\..\..\..\manifest.json"
	rem Convert manifestpath from relative to absolute path
	CALL :NORMALIZEPATH "!manifestPath!"
	set "manifestpath=!retval!"
	echo %DATE% %TIME% Expected location for manifest.json is !manifestPath!  >> "%log_file%"
	echo Folder structure:%ESC%[0;93m Non-modular MSFS 2024 aircraft %ESC%[0m
) else if exist !Tex_path!\..\..\..\..\..\..\..\layout.json (
	set "layoutPath=!Tex_path!\..\..\..\..\..\..\..\layout.json"
	rem Convert layoutpath from relative to absolute path
	CALL :NORMALIZEPATH "!layoutPath!"
	set "layoutpath=!retval!"
	echo %DATE% %TIME% !layoutPath! exists, this is a modular MSFS 2024 aircraft  >> "%log_file%"
	echo Found:%ESC%[0;93m !layoutPath! %ESC%[0m
	set "manifestPath=!Tex_path!\..\..\..\..\..\..\..\manifest.json"
	rem Convert manifestpath from relative to absolute path
	CALL :NORMALIZEPATH "!manifestPath!"
	set "manifestpath=!retval!"
	echo %DATE% %TIME% Expected location for manifest.json is !manifestPath!  >> "%log_file%"
	echo Folder structure:%ESC%[0;93m Modular MSFS 2024 aircraft %ESC%[0m
) else (
cls
echo %DATE% %TIME% Could not find layout.json  >> "%log_file%"
echo %ESC%[0;91mCannot find layout.json, please check your livery folder structure and content is valid. %ESC%[0m
echo See MSFS 2024 SDK documentation for more details on the expected folder structure.
echo Press any key to return to the Configuration Menu...
pause >NUL
GOTO CONFIGMENU
)
echo %DATE% %TIME% Ended function READLAYOUT >> "%log_file%"
Exit /B

:NORMALIZEPATH
  SET RETVAL=%~f1
  rem echo normalized path is %RETVAL%
  rem pause
  EXIT /B

:READMANIFEST
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
echo %DATE% %TIME% Started function READMANIFEST >> "%log_file%"
rem Read the livery title from manifest.json, which should be in the same folder as layout.json
echo %DATE% %TIME% Check if !manifestPath! exists >> "%log_file%"
if exist !manifestPath! (
			echo Found:%ESC%[0;93m !manifestPath!  %ESC%[0m
			echo Reading manifest.json...
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
				echo Successfully found the livery titled:%ESC%[0;93m !LiveryTitle! %ESC%[0m
				echo %DATE% %TIME% Found livery titled: !LiveryTitle! >> "%log_file%"
			rem Pause
			) else (
			echo %ESC%[0;91mCannot find: !manifestPath!, please check your livery folder structure and content is valid. %ESC%[0m
			echo %DATE% %TIME% Could not find !manifestPath! >> "%log_file%"
			)
echo %DATE% %TIME% Ended function READMANIFEST >> "%log_file%"
Exit /B

:WRITESETTINGS
rem Write variables to settings files
SET "AppVersion=%CurrentAppVersion%"
echo %DATE% %TIME% Updating the settings file >> "%log_file%"
(
echo AppVersion=%AppVersion%
echo SimType=%simType%
echo sdk_root=!sdk_root!
echo LG_path=!LG_path!
echo Tex_path=!Tex_path!
echo HQ_Flag_Albd=!HQ_Flag_Albd!
echo NoAlpha_Flag_Albd=!NoAlpha_Flag_Albd!
echo HQ_Flag_Decal=!HQ_Flag_Decal!
echo NoAlpha_Flag_Decal=!NoAlpha_Flag_Decal!
)>userConfig.ini 
Exit /B



rem Subroutine to calculate the length of a string
:strlen
setlocal enabledelayedexpansion
set "string=%~2"
set /a length=0

:strlenLoop
if defined string (
    set "string=!string:~1!"
    set /a length+=1
    goto :strlenLoop
)
rem echo %length%
endlocal & set "%~1=%length%"
exit /b


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
echo %DATE% %TIME% Read settings from settings file: HQ_Flag_Albd is !HQ_Flag_Albd! >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: NoAlpha_Flag_Albd is !NoAlpha_Flag_Albd! >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: HQ_Flag_Decal is !HQ_Flag_Decal! >> "%log_file%"
echo %DATE% %TIME% Read settings from settings file: NoAlpha_Flag_Decal is !NoAlpha_Flag_Decal! >> "%log_file%"

rem Check if HQ_Flag_Albd is defined
if not defined HQ_Flag_Albd (
echo %DATE% %TIME% HQ_Flag_Albd is: !HQ_Flag_Albd! >> "%log_file%"
echo %DATE% %TIME% HQ_Flag_Albd value was NULL, setting it to ON >> "%log_file%"
set HQ_Flag_Albd=ON
call :WRITESETTINGS
echo %DATE% %TIME% Read settings from settings file: HQ_Flag_Albd is !HQ_Flag_Albd! >> "%log_file%"
)

rem Check if NoAlpha_Flag_Albd is defined
if not defined NoAlpha_Flag_Albd (
echo %DATE% %TIME% NoAlpha_Flag_Albd is: !NoAlpha_Flag_Albd! >> "%log_file%"
echo %DATE% %TIME% NoAlpha_Flag_Albd value was NULL, setting it to OFF >> "%log_file%"
set NoAlpha_Flag_Albd=OFF
call :WRITESETTINGS
echo %DATE% %TIME% Read settings from settings file: NoAlpha_Flag_Albd is !NoAlpha_Flag_Albd! >> "%log_file%"
)

rem Check if HQ_Flag_Decal is defined
if not defined HQ_Flag_Decal (
echo %DATE% %TIME% HQ_Flag_Decal is: !HQ_Flag_Decal! >> "%log_file%"
echo %DATE% %TIME% HQ_Flag_Decal value was NULL, setting it to ON >> "%log_file%"
set HQ_Flag_Decal=ON
call :WRITESETTINGS
echo %DATE% %TIME% Read settings from settings file: HQ_Flag_Decal is !HQ_Flag_Decal! >> "%log_file%"
)

rem Check if NoAlpha_Flag_Decal is defined
if not defined NoAlpha_Flag_Decal (
echo %DATE% %TIME% NoAlpha_Flag_Decal is: !NoAlpha_Flag_Decal! >> "%log_file%"
echo %DATE% %TIME% NoAlpha_Flag_Decal value was NULL, setting it to OFF >> "%log_file%"
set NoAlpha_Flag_Decal=OFF
call :WRITESETTINGS
echo %DATE% %TIME% Read settings from settings file: NoAlpha_Flag_Decal is !NoAlpha_Flag_Decal! >> "%log_file%"
)


if exist "!sdk_root!\version.txt" (
set /p sdkVer=<!sdk_root!\version.txt
echo %DATE% %TIME% MSFS SDK version: !sdkVer! >> "%log_file%"
) else (
set sdkVer=Unknown
)
cls
)

rem Build the flag strings for the ALBEDO KTX2 files

if %HQ_Flag_Albd%==ON (
	if %NoAlpha_Flag_Albd%==ON (
	rem HQ_Flag_Albd is ON + NoAlpha_Flag_Albd is ON
	echo %DATE% %TIME% HQ_Flag_Albd is ON + NoAlpha_Flag_Albd is ON >> "%log_file%"
	set "AlbedoFlags=<UserFlags Type="_DEFAULT">QUALITYHIGH</UserFlags><ForceNoAlpha>true</ForceNoAlpha>"
	echo %DATE% %TIME% AlbedoFlags: !AlbedoFlags! >> "%log_file%"
	) else (
	rem HQ_Flag_Albd is ON + NoAlpha_Flag_Albd is OFF
	echo %DATE% %TIME% HQ_Flag_Albd is ON + NoAlpha_Flag_Albd is OFF
	set "AlbedoFlags=<UserFlags Type="_DEFAULT">QUALITYHIGH</UserFlags><ForceNoAlpha>false</ForceNoAlpha>"
	echo %DATE% %TIME% AlbedoFlags: !AlbedoFlags! >> "%log_file%"
	)
) else (
	if %NoAlpha_Flag_Albd%==ON (
	rem HQ_Flag_Albd is OFF + NoAlpha_Flag_Albd is ON
	echo %DATE% %TIME% HQ_Flag_Albd is OFF + NoAlpha_Flag_Albd is ON >> "%log_file%"
	set "AlbedoFlags=<UserFlags Type="_DEFAULT"></UserFlags><ForceNoAlpha>true</ForceNoAlpha>"
	echo %DATE% %TIME% AlbedoFlags: !AlbedoFlags! >> "%log_file%"
	) else (
	rem HQ_Flag_Albd is OFF + NoAlpha_Flag_Albd is OFF
	echo %DATE% %TIME% HQ_Flag_Albd is OFF + NoAlpha_Flag_Albd is OFF >> "%log_file%"
	set "AlbedoFlags=<UserFlags Type="_DEFAULT"></UserFlags><ForceNoAlpha>false</ForceNoAlpha>"
	echo %DATE% %TIME% AlbedoFlags: !AlbedoFlags! >> "%log_file%"
	)
)

rem Build the flag strings for the DECAL KTX2 files

if %HQ_Flag_Decal%==ON (
	if %NoAlpha_Flag_Decal%==ON (
	rem HQ_Flag_Decal is ON + NoAlpha_Flag_Decal is ON
	echo %DATE% %TIME% HQ_Flag_Decal is ON + NoAlpha_Flag_Decal is ON >> "%log_file%"
	set "DecalFlags=<UserFlags Type="_DEFAULT">QUALITYHIGH</UserFlags><ForceNoAlpha>true</ForceNoAlpha>"
	echo %DATE% %TIME% DecalFlags: !DecalFlags! >> "%log_file%"
	) else (
	rem HQ_Flag_Decal is ON + NoAlpha_Flag_Decal is OFF
	echo %DATE% %TIME% HQ_Flag_Decal is ON + NoAlpha_Flag_Decal is OFF
	set "DecalFlags=<UserFlags Type="_DEFAULT">QUALITYHIGH</UserFlags><ForceNoAlpha>false</ForceNoAlpha>"
	echo %DATE% %TIME% DecalFlags: !DecalFlags! >> "%log_file%"
	)
) else (
	if %NoAlpha_Flag_Decal%==ON (
	rem HQ_Flag_Decal is OFF + NoAlpha_Flag_Decal is ON
	echo %DATE% %TIME% HQ_Flag_Decal is OFF + NoAlpha_Flag_Decal is ON >> "%log_file%"
	set "DecalFlags=<UserFlags Type="_DEFAULT"></UserFlags><ForceNoAlpha>true</ForceNoAlpha>"
	echo %DATE% %TIME% DecalFlags: !DecalFlags! >> "%log_file%"
	) else (
	rem HQ_Flag_Decal is OFF + NoAlpha_Flag_Decal is OFF
	echo %DATE% %TIME% HQ_Flag_Decal is OFF + NoAlpha_Flag_Decal is OFF >> "%log_file%"
	set "DecalFlags=<UserFlags Type="_DEFAULT"></UserFlags><ForceNoAlpha>false</ForceNoAlpha>"
	echo %DATE% %TIME% DecalFlags: !DecalFlags! >> "%log_file%"
	)
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
set maxPathLength=0
for %%f in ("%ALBD_dir%\*.png") do (set /a albdCount+=1)
for %%f in ("%ALBD_dir%\*.tif") do (set /a albdCount+=1)
echo %DATE% %TIME% Found !albdCount! albedo image files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (set /a compCount+=1)
for %%f in ("%COMP_dir%\*.tif") do (set /a compCount+=1)
echo %DATE% %TIME% Found !compCount! composite image files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (set /a normCount+=1)
for %%f in ("%NORM_dir%\*.tif") do (set /a normCount+=1)
echo %DATE% %TIME% Found !normCount! normal map image files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (set /a decalCount+=1)
for %%f in ("%DECAL_dir%\*.tif") do (set /a decalCount+=1)
echo %DATE% %TIME% Found !decalCount! decal image files >> "%log_file%"

cls

echo %DATE% %TIME% Display list of files >> "%log_file%"
ECHO                    IMAGE TO MSFS KTX2 CONVERTER v%CurrentAppVersion%                      
ECHO ==================================================================================
set count=0
if !albdCount! gtr 0 (
ECHO ---------------------------- ALBEDO PNG / TIF files ------------------------------
echo %DATE% %TIME% Checking albedo files >> "%log_file%"
) else (
ECHO.
ECHO ---------------------------- ALBEDO PNG / TIF files ------------------------------
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
FOR %%f in (".\ALBD\*.tif") do (
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
if !compCount! gtr 0 (
ECHO.
ECHO --------------------------- COMPOSITE PNG / TIF files ----------------------------
echo %DATE% %TIME% Checking comp files >> "%log_file%"
) else (
ECHO.
ECHO --------------------------- COMPOSITE PNG / TIF files ----------------------------
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
FOR %%f in (".\COMP\*.tif") do (
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
ECHO ---------------------------- NORMAL PNG / TIF files ------------------------------
echo %DATE% %TIME% Checking norm files >> "%log_file%"
) else (
ECHO.
ECHO ---------------------------- NORMAL PNG / TIF files ------------------------------
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
FOR %%f in (".\NORM\*.tif") do (
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
ECHO ---------------------------- DECAL TIF / PNG files -------------------------------
echo %DATE% %TIME% Checking decal files >> "%log_file%"
) else (
ECHO.
ECHO ---------------------------- DECAL TIF / PNG files -------------------------------
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
ECHO ----------------------------------- COMMANDS  ------------------------------------
echo %DATE% %TIME% Display command list >> "%log_file%"
ECHO %ESC%[0;104m 1 %ESC%[0m - Edit Settings 
ECHO %ESC%[0;104m 2 %ESC%[0m - Generate missing XML files for !countWithoutXML! of !totalCount! image files
ECHO %ESC%[0;104m 3 %ESC%[0m - Regenerate XML files for all !totalCount! image files
if !countWithoutXML! gtr 0 (
ECHO  %ESC%[0;90m4  - Generate KTX2 files in the OUTPUT folder [COMMAND UNAVAILABLE]%ESC%[0m
) else (
ECHO %ESC%[0;104m 4 %ESC%[0m - Generate KTX2 files in the OUTPUT folder
)
if %EnableOption5%==true (
ECHO %ESC%[0;104m 5 %ESC%[0m - Generate KTX2 files in aircraft texture folder and run MSFSLayoutGenerator.exe
) else (
ECHO %ESC%[0;90m 5  - Generate KTX2 files in aircraft texture folder and run MSFSLayoutGenerator.exe [COMMAND UNAVAILABLE]%ESC%[0m
)
ECHO %ESC%[0;104m 6 %ESC%[0m - Refresh
ECHO %ESC%[0;104m 7 %ESC%[0m - Exit
ECHO.
SET /P M=Choose an %ESC%[0;104moption%ESC%[0m then press ENTER: 
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
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
echo %DATE% %TIME% Display configuration menu list >> "%log_file%"
CLS
ECHO --------------------------------------------- CONFIGURATION ---------------------------------------------
ECHO %ESC%[0;104m 1 %ESC%[0m - Edit SDK path
ECHO %ESC%[0;93m%sdk_root% %ESC%[0m
ECHO SDK version detected as: %ESC%[0;93m%sdkVer% %ESC%[0m
ECHO.
ECHO %ESC%[0;104m 2 %ESC%[0m - Change MSFS 2024 version
ECHO %ESC%[0;93m%simType% %ESC%[0m
ECHO.
ECHO %ESC%[0;104m 3 %ESC%[0m - Edit MSFSLayoutGenerator path (Optional: updates the layout.json file of an existing livery project)
ECHO %ESC%[0;93m%LG_path% %ESC%[0m
ECHO.
ECHO %ESC%[0;104m 4 %ESC%[0m - Edit Livery texture path (Optional: output the KTX2 files directly to an existing livery project)
ECHO %ESC%[0;93m%Tex_path% %ESC%[0m
ECHO -------------------------------------------- TEXTURE FLAGS ---------------------------------------------
ECHO QUALITYHIGH - uses higher compression quality, but increases memory usage and KTX2 file size
ECHO ForceNoAlpha - removes alpha channel from KTX2 file when ON
ECHO.
echo ALBEDO     :       %ESC%[0;104m 5 %ESC%[0m QUALITYHIGH=%ESC%[0;93m%HQ_Flag_Albd% %ESC%[0m ^| %ESC%[0;104m 6 %ESC%[0m ForceNoAlpha=%ESC%[0;93m%NoAlpha_Flag_Albd% %ESC%[0m
ECHO.
echo COMPOSITE  :          %ESC%[0;90m QUALITYHIGH=ON  ^|     ForceNoAlpha=OFF%ESC%[0m
ECHO.
echo NORMAL     :          %ESC%[0;90m QUALITYHIGH=ON  ^|     ForceNoAlpha=OFF%ESC%[0m
ECHO.
echo DECAL      :       %ESC%[0;104m 7 %ESC%[0m QUALITYHIGH=%ESC%[0;93m%HQ_Flag_Decal% %ESC%[0m ^| %ESC%[0;104m 8 %ESC%[0m ForceNoAlpha=%ESC%[0;93m%NoAlpha_Flag_Decal% %ESC%[0m
echo --------------------------------------------------------------------------------------------------------
ECHO.
ECHO %ESC%[0;104m 9 %ESC%[0m - Go back to main menu
ECHO.
SET /P S=Choose an %ESC%[0;104moption%ESC%[0m then press ENTER: 
IF %S%==1 GOTO SDKPATHMENU
IF %S%==2 GOTO SIMTYPEMENU
IF %S%==3 GOTO LAYOUTGEN
IF %S%==4 GOTO LIVERYTEX
IF %S%==5 GOTO HQFLAGTOGGLEALBD
IF %S%==6 GOTO NOALPHAFLAGTOGGLEALBD
IF %S%==7 GOTO HQFLAGTOGGLEDECAL
IF %S%==8 GOTO NOALPHAFLAGTOGGLEDECAL
IF %S%==9 GOTO MENU
rem User input a different value, try again!
CLS
goto CONFIGMENU


:CREATEXMLS
echo %DATE% %TIME% User chose option 2 >> "%log_file%"
echo %DATE% %TIME% Creating missing XMLs for albedo PNG files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpnf >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!AlbedoFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
rem echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for albedo TIF files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.tif") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!AlbedoFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for composite PNG files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for composite TIF files >> "%log_file%"
for %%f in ("%COMP_dir%\*.tif") do (
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
echo %DATE% %TIME% Creating missing XMLs for normal TIF files >> "%log_file%"
for %%f in ("%NORM_dir%\*.tif") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for decal PNG files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff>> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!DecalFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
echo %DATE% %TIME% Creating missing XMLs for decal TIF files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.tif") do (
if not exist "%%~dpnf.xml" (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!DecalFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
)
)
cls
goto MENU
:RECREATEXMLS
echo %DATE% %TIME% User chose option 3 >> "%log_file%"
echo %DATE% %TIME% Recreating XMLs for albedo PNG files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!AlbedoFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for albedo TIF files >> "%log_file%"
for %%f in ("%ALBD_dir%\*.tif") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!AlbedoFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for composite PNG files >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for composite TIF files >> "%log_file%"
for %%f in ("%COMP_dir%\*.tif") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_METAL_ROUGH_AO^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^<ForceNoAlpha^>true^</ForceNoAlpha^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for normal PNG files >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for normal TIF files >> "%log_file%"
for %%f in ("%NORM_dir%\*.tif") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_NORMAL^</BitmapSlot^>^<UserFlags Type="_DEFAULT"^>QUALITYHIGH^</UserFlags^>^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for decal PNG files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.png") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!DecalFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
)
echo %DATE% %TIME% Recreating XMLs for decal TIF files >> "%log_file%"
for %%f in ("%DECAL_dir%\*.tif") do (
echo %DATE% %TIME% ...Creating XML file for %%~dpff >> "%log_file%"
echo ^<BitmapConfiguration^>^<BitmapSlot^>MTL_BITMAP_DECAL0^</BitmapSlot^>!DecalFlags!^</BitmapConfiguration^> > "%%~dpff.xml"
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
rem Determine the length of the texture path, if it's defined
rem Set the string (path) to calculate the length for
set string=!tex_Path!
rem Initialize length counter
set /a PathLength=0

rem Loop through the string character by character
:calculate_length
if not "%string%"=="" (
    set "string=!string:~1!"
    set /a PathLength+=1
    goto :calculate_length
)

rem Determine the length of filenames and update maxPathLength
Echo Analysing texture image files...
for %%f in ("%ALBD_dir%\*.png" "%ALBD_dir%\*.tif" "%COMP_dir%\*.png" "%COMP_dir%\*.tif" "%NORM_dir%\*.png" "%NORM_dir%\*.tif" "%DECAL_dir%\*.png" "%DECAL_dir%\*.tif") do (
    set "filename=%%~nxf"
    call :strlen stringlength !filename!
	rem echo !filename!
	rem echo !stringlength!
	rem pause
	if !stringlength! gtr !maxPathLength! (set maxPathLength=!stringlength!)
	echo Longest filename length is: !maxPathLength! chars >> "%log_file%"
	rem echo.
)
cls
rem echo The max path length is: %maxPathLength%
rem Display the length of the string
rem echo The length of the string is: %PathLength%

rem Combine texture path and longest file name, then add 12 chars
set /a TotalPathLength = %maxPathLength%+%PathLength%+12
if %TotalPathLength% gtr 260 (
echo One or more of the texture file names will result in a path length of %TotalPathLength% characters. 
echo The KTX2 generation will fail for paths over 260 characters. Use a shorter path for your aircraft texture path.
echo Press any key to return to the main menu...
pause >nul
goto MENU
)

IF !M!==5 (
	echo %DATE% %TIME% User chose option 5 >> "%log_file%"
	echo %DATE% %TIME% Check if "%LG_path%\MSFSLayoutGenerator.exe" exists >> "%log_file%"
		if exist "%LG_path%\MSFSLayoutGenerator.exe" (
		echo %DATE% %TIME% "%LG_path%\MSFSLayoutGenerator.exe" found OK >> "%log_file%"
		CALL :READLAYOUT
		CALL :READMANIFEST
		echo.
		echo Press any key to proceed with KTX2 creation, or close this window to cancel.
		pause >nul
		) else (
		echo %DATE% %TIME% "%LG_path%\MSFSLayoutGenerator.exe" not found >> "%log_file%"
		ECHO Could not find MSFSLayoutGenerator.exe at %LG_path%. Check the specified path in the configuration menu.
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
rem Copy Albedo PNG TIF and XML files
echo %DATE% %TIME% For each PNG in !ALBD_dir!... >> "%log_file%"
for %%f in ("%ALBD_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
echo %DATE% %TIME% For each TIF in !ALBD_dir!... >> "%log_file%"
for %%f in ("%ALBD_dir%\*.tif") do (
if exist "%%~dpnf.tif" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.tif" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.tif" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Copy Composite PNG TIF and XML files
echo %DATE% %TIME% For each PNG in !COMP_dir!... >> "%log_file%"
for %%f in ("%COMP_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.png" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
echo %DATE% %TIME% For each TIF in !COMP_dir!... >> "%log_file%"
for %%f in ("%COMP_dir%\*.tif") do (
if exist "%%~dpnf.tif" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.tif" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.tif" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
rem Normal PNG TIF and XML files
echo %DATE% %TIME% For each PNG in !NORM_dir!... >> "%log_file%"
for %%f in ("%NORM_dir%\*.png") do (
if exist "%%~dpnf.png" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.png" to "..\PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.png" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
)
)
echo %DATE% %TIME% For each TIF in !NORM_dir!... >> "%log_file%"
for %%f in ("%NORM_dir%\*.tif") do (
if exist "%%~dpnf.tif" (
echo %DATE% %TIME% ...Copy "%%~dpff.xml" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpff.xml" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
echo %DATE% %TIME% ...Copy "%%~dpnf.tif" to "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
copy /y "%%~dpnf.tif" "%~dp0PackageSources\SimObjects\Airplanes\png-2-ktx2\common\texture\" >> "%log_file%"
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
echo Step 3 of 3: Completed generation of KTX2 files. 
echo Press any key to clean up temporary files, update the livery layout.json and finish.
echo %DATE% %TIME% Step 3 of 3: Completed generation of KTX2 files. Press any key to clean up temporary files and finish.  >> "%log_file%"
color 2f
) else (
echo Step 3 of 3: Completed generation of KTX2 files. 
echo Press any key to clean up temporary files and finish.
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
set OutputPath=%~dp0OUTPUT
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
echo Running MSFSLayoutGenerator.exe on "%layoutPath%"
echo %DATE% %TIME% Run MSFSLayoutGenerator.exe on "%layoutPath%" >> "%log_file%"
echo %DATE% %TIME% Command: "%LG_path%\MSFSLayoutGenerator.exe" "%layoutPath%" >> "%log_file%"
rem run MSFSLayoutGenerator.exe
"%LG_path%\MSFSLayoutGenerator.exe" "%layoutPath%"
set OutputPath=!Tex_path!
) 
echo %DATE% %TIME% Open the folder "%OutputPath%" >> "%log_file%"
start "" "%OutputPath%"
echo Done! This window will close in 20s, or press any key to close it now...
timeout /t 20 >nul
echo %DATE% %TIME% End of script >> "%log_file%"
goto EOF
:REFRESH
CLS
echo %DATE% %TIME% Refresh menu >> "%log_file%"
goto MENU
