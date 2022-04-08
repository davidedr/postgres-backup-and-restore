REM @ECHO OFF
CLS
set TOKEEP=3
set TARGET_DIR=C:\BACKUP
set TARGET=%TARGET_DIR%\*.databasedump.log
dir /b /O-D %TARGET%
for /f "delims=, skip=%TOKEEP%" %%f in ('dir /b /O-D %TARGET%') do dir %TARGET_DIR%\%%f
REM for /f "delims=, skip=%TOKEEP%" %%f in ('dir /b C:\BACKUP\*.databasedump.log') do del %TARGET_DIR%\%%f
