REM GOTO:EOF
@echo off
set path_to_script=%~dp0
cd %path_to_script%
echo "%PROCESSOR_ARCHITECTURE%" | find /i "x86" > NUL && set OS=86 && set CYG_PREFIX=cygwin || set OS=86_64 && set CYG_PREFIX=cygwin64
set URL=https://cygwin.com/setup-x%OS%.exe
set CYGWIN_INSTALLER_BIN=%TEMP%\cygwin_installer.exe
set CYGWIN_PATH=%SYSTEMDRIVE%\%CYGWINPATH%
set TERMINAL_BIN=%CYGWIN_PATH%\bin\mintty.exe
if not exist %CYGWIN_INSTALLER_BIN% bitsadmin /Transfer downloadcygwinjob %URL% %CYGWIN_INSTALLER_BIN%
if not exist %TERMINAL_BIN% %CYGWIN_INSTALLER_BIN% --quiet-mode --packages rsync,openssh,git,nano,mc
call set path_reversed_slashes=%%path_to_script:\=/%%
call set converted_cygwin_path=/cygdrive/%%path_reversed_slashes::=%%
echo %converted_cygwin_path%/send_sshkey.sh
%TERMINAL_BIN% -e "/bin/bash" -l -i %converted_cygwin_path%/sync.sh
