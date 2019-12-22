@echo off

::Borrowed from @abbodi1406's scripts
for /f "tokens=6 delims=[]. " %%i in ('ver') do set build=%%i

if %build% LSS 17763 (
    echo =============================================================
    echo This script is compatible only with Windows 10 RS5 and later.
    echo =============================================================
    echo.
    pause
    goto :EOF
)

REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1
IF %ERRORLEVEL% EQU 0 goto :START_SCRIPT

echo =====================================================
echo This script needs to be executed as an administrator.
echo =====================================================
echo.
pause
goto :EOF

:START_SCRIPT
set "FlightSigningEnabled=0"
bcdedit /enum {current} | findstr /I /R /C:"^flightsigning *Yes$" >NUL 2>&1
IF %ERRORLEVEL% EQU 0 set "FlightSigningEnabled=1"

:CHOICE_MENU
cls
set "choice="
echo OfflineInsiderEnroll v1.0.0
echo.
echo R - Enroll to Release Preview ring
echo S - Enroll to Insider Slow ring
echo F - Enroll to Insider Fast ring
echo.
echo X - Stop receiving Insider Preview builds
echo Q - Quit without making any changes
echo.
set /p choice="Choice: "
echo.
if /I "[%choice%]"=="[r]" goto :ENROLL_RP
if /I "[%choice%]"=="[s]" goto :ENROLL_SLOW
if /I "[%choice%]"=="[f]" goto :ENROLL_FAST
if /I "[%choice%]"=="[x]" goto :STOP_INSIDER
if /I "[%choice%]"=="[q]" goto :EOF
goto :CHOICE_MENU

:ENROLL_RP
set "SLS=RingPreview"
set "Ring=RP"
set "Content=Current"
set "FancyRing=Release Preview"
goto :ENROLL

:ENROLL_SLOW
set "SLS=RingInsiderSlow"
set "Ring=WIS"
set "Content=Active"
set "FancyRing=Windows Insider Slow"
goto :ENROLL

:ENROLL_FAST
set "SLS=RingInsiderFast"
set "Ring=WIF"
set "Content=Active"
set "FancyRing=Windows Insider Fast"
goto :ENROLL

:RESET_INSIDER_CONFIG
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost" /f >NUL 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" /f >NUL 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingPreview" /f >NUL 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderSlow" /f >NUL 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderFast" /f >NUL 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /f >NUL 2>&1
goto :EOF

:ENROLL
echo Applying changes...
call :RESET_INSIDER_CONFIG
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator" /t REG_DWORD /v EnableUUPScan /d 1 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\%SLS%" /t REG_DWORD /v Enabled /d 1 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" /t REG_DWORD /v WUMUDCATEnabled /d 1 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v EnablePreviewBuilds /d 1 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v IsBuildFlightingEnabled /d 1 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v TestFlags /d 32 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_SZ /v ContentType /d "%Content%" /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_SZ /v BranchName /d "external" /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_SZ /v Ring /d "%Ring%" /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /t REG_SZ /v StickyXaml /d "<StackPanel xmlns="^""http://schemas.microsoft.com/winfx/2006/xaml/presentation"^""><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">This device has been enrolled to the Windows Insider program using a OfflineInsiderEnroll script. If you want to change settings of the enrollment or stop receiving Insider Preview builds, please use the script. <Hyperlink NavigateUri="^""https://github.com/whatever127/offlineinsiderenroll/blob/master/readme.md"^"" TextDecorations="^""None"^"">Learn more</Hyperlink></TextBlock><TextBlock Text="^""Applied configuration"^"" Margin="^""0,20,0,10"^"" Style="^""{StaticResource SubtitleTextBlockStyle}"^"" /><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"" Margin="^""0,0,0,5"^""><Run FontFamily="^""Segoe MDL2 Assets"^"">&#xECA7;</Run> <Span FontWeight="^""SemiBold"^"">%FancyRing%</Span></TextBlock><TextBlock Text="^""Ring: %Ring%"^"" Style="^""{StaticResource BodyTextBlockStyle }"^"" /><TextBlock Text="^""Content: %Content%"^"" Style="^""{StaticResource BodyTextBlockStyle }"^"" /></StackPanel>" /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIHiddenElements /d 65535 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIDisabledElements /d 65535 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIServiceDrivenElementVisibility /d 0 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIErrorMessageVisibility /d 192 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /t REG_DWORD /v AllowTelemetry /d 3 /f >NUL 2>&1

bcdedit /set {current} flightsigning yes >NUL 2>&1
echo Done.

echo.
IF %FlightSigningEnabled% NEQ 1 goto :ASK_FOR_REBOOT
pause
goto :EOF

:STOP_INSIDER
echo Applying changes...
call :RESET_INSIDER_CONFIG
bcdedit /deletevalue {current} flightsigning >NUL 2>&1
echo Done.

echo.
IF %FlightSigningEnabled% NEQ 0 goto :ASK_FOR_REBOOT
pause
goto :EOF

:ASK_FOR_REBOOT
set "choice="
echo A reboot is required to finish applying changes.
set /p choice="Would you like to reboot your PC? (y/N) "
if /I "[%choice%]"=="[y]" shutdown -r -t 0
goto :EOF
