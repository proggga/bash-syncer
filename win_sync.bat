@echo off
cd %~dp0
echo "%PROCESSOR_ARCHITECTURE%" | find /i "x86" > NUL && set OS=86 || set OS=86_64
echo %OS%
set URL=https://cygwin.com/setup-x%OS%.exe
set CYGWIN=%TEMP%\cygwin_installer.exe
set TERMINAL=C:\cygwin64\bin\mintty.exe
if not exist %CYGWIN% bitsadmin /Transfer downloadcygwinjob %URL% %CYGWIN%
if not exist %TERMINAL% %CYGWIN% --quiet-mode --packages rsync,openssh,git,nano,mc
set str=%~dp0
call set str=%%str:\=/%%
call set str=%%str::=%%
echo /cygdrive/%str%/send_sshkey.sh
%TERMINAL% -h always -e "/bin/bash" -l -i /cygdrive/%str%sync.sh
