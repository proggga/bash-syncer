@echo off
cd %~dp0
echo "%PROCESSOR_ARCHITECTURE%" | find /i "x86" > NUL && set OS=86 || set OS=86_64
echo %OS%
set URL=https://cygwin.com/setup-x%OS%.exe
set CYGWIN=%TEMP%\cygwin_installer.exe
set TERMINAL=C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -
if not exist %CYGWIN% bitsadmin /Transfer downloadcygwinjob %URL% %CYGWIN%
if not exist %TERMINAL% --quiet-mode --packages rsync,openssh,git
set str=%~dp0
call set str=%%str:\=/%%
call set str=%%str::=%%
echo /cygdrive/%str%
:: %TERMINAL% "/cygwin/%O
