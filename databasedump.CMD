ECHO OFF
cls
set BACKUP_FOLDER_GENERAL=C:\BACKUP

REM Data corrente: 05/04/2022
set CUR_YYYY=%date:~6,4%
set CUR_MM=%date:~3,2%
set CUR_DD=%date:~0,2%
set CUR_HH=%time:~0,2%
if %CUR_HH% lss 10 (set CUR_HH=0%time:~1,1%)

set CUR_NN=%time:~3,2%
set CUR_SS=%time:~6,2%
set CUR_MS=%time:~9,2%

set SUBFILENAME=%CUR_YYYY%%CUR_MM%%CUR_DD%-%CUR_HH%%CUR_NN%%CUR_SS%
REM ECHO %SUBFILENAME%

set LOGFILE=%BACKUP_FOLDER_GENERAL%\%CUR_YYYY%%CUR_MM%%CUR_DD%-%CUR_HH%%CUR_NN%%CUR_SS%.databasedump.log
echo Database dump %SUBFILENAME% >> %LOGFILE%
echo LOGFILE: %LOGFILE% >> %LOGFILE%

echo Data folder file-level backup... >> %LOGFILE%
set BACKUP_FOLDER=%BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_DATA
echo BACKUP_FOLDER: %BACKUP_FOLDER% >> %LOGFILE%
md %BACKUP_FOLDER% >> %LOGFILE%

REM
REM Folder level backup
REM

REM dir "c:\Program Files\PostgreSQL\9.6\data\postmaster.pid"
REM "C:\Program Files\PostgreSQL\9.6\bin\pg_ctl.exe" runservice -N "postgresql-x64-9.6" -D "C:\Program Files\PostgreSQL\9.6\data" -w

REM "c:\Program Files\PostgreSQL\9.6\bin\pg_ctl.exe" stop -D "C:\Program Files\PostgreSQL\9.6\data" >> %LOGFILE%
net stop postgresql-x64-9.6 >> %LOGFILE%
xcopy C:\"Program Files"\PostgreSQL\9.6\data %BACKUP_FOLDER% /E >> %LOGFILE%
REM "c:\Program Files\PostgreSQL\9.6\bin\pg_ctl.exe" start -D "C:\Program Files\PostgreSQL\9.6\data" >> %LOGFILE%
net start postgresql-x64-9.6 >> %LOGFILE%

.\7-Zip\7z a -tzip %BACKUP_FOLDER%.zip %BACKUP_FOLDER% >> %LOGFILE%

rmdir /S /Q %BACKUP_FOLDER% >> %LOGFILE%

REM
REM To restore:
REM unzip folder
REm assign all permissions to user
REM execute "c:\Program Files\PostgreSQL\9.6\bin\pg_ctl.exe" -D c:/backup/20220402-171414_DATA start
REM maybe you want to change the port in postgresql.conf
REM see also:
REM https://stackoverflow.com/questions/26441873/starting-postgresql-and-pgadmin-in-windows-without-installation
REM 

REM
REM sql format database
REM 

echo SQL schema only backup... >> %LOGFILE%
set PGPASSWORD=postgres
"c:\Program Files\PostgreSQL\9.6\bin\pg_dump.exe" -Z 6 -U postgres --serializable-deferrable -C -f %BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_counters_schema_only.sql -h localhost -p 5432 -s counters >> %LOGFILE%
set PGPASSWORD=

echo SQL data only backup... >> %LOGFILE%
REM -b useless w/ -a option: -b is default behaviour except when --schema, --table, or --schema-only is specified
set PGPASSWORD=postgres
"c:\Program Files\PostgreSQL\9.6\bin\pg_dump.exe" -Z 6 -U postgres --serializable-deferrable -C -f %BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_counters_data_only.sql -h localhost -p 5432 -a --column-inserts --inserts counters >> %LOGFILE%
set PGPASSWORD=

echo SQL schema and data backup... >> %LOGFILE%
set PGPASSWORD=postgres
"c:\Program Files\PostgreSQL\9.6\bin\pg_dump.exe" -Z 6 -U postgres --serializable-deferrable -C -f %BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_counters_schema_data.sql -h localhost -p 5432 --column-inserts --inserts --disable-triggers counters >> %LOGFILE%
set PGPASSWORD=

REM
REM Restore these files w/:
REM "c:\Program Files\PostgreSQL\11\bin\pg_sql.exe" -U postgres -C -d postgres -p 5433 %BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_counters_schema_data.sql
REM

REM
REM -F c format database
REM 

echo -F c backup... >> %LOGFILE%
set PGPASSWORD=postgres
"c:\Program Files\PostgreSQL\9.6\bin\pg_dump.exe" -F c -Z 6 -U postgres --serializable-deferrable -C -f %BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_counters_schema_data.custom_format -h localhost -p 5432 --column-inserts --inserts --disable-triggers counters >> %LOGFILE%
set PGPASSWORD=

REM to restore from -F c pg_dump-ed file, use:
REM
REM "c:\Program Files\PostgreSQL\11\bin\pg_restore.exe" -U postgres -C -d postgres -p 5433 %BACKUP_FOLDER_GENERAL%\%SUBFILENAME%_counters_schema_data.custom_format
REM
REM The database named in the -d switch can be any database existing in the cluster; pg_restore only uses it to issue the CREATE DATABASE command for mydb.
REM With -C, data is always restored into the database name that appears in the dump file.
REM Ignore the three lines of error that appears

REM
REM Only keep last n backup items
REM

dir /b *.databasedump.log
for /f "delims=, skip=10" %f in ('dir /b *.databasedump.log') do dir %f
for /f "delims=, skip=10" %f in ('dir /b *.databasedump.log') do del %f

REM
REM Report processing conclusion
REM

set CUR_YYYY=%date:~6,4%
set CUR_MM=%date:~3,2%
set CUR_DD=%date:~7,2%
set CUR_HH=%time:~0,2%
if %CUR_HH% lss 10 (set CUR_HH=0%time:~1,1%)

set CUR_NN=%time:~3,2%
set CUR_SS=%time:~6,2%
set CUR_MS=%time:~9,2%
set TERMINATION_TIMESTAMP=%CUR_YYYY%%CUR_MM%%CUR_DD%-%CUR_HH%%CUR_NN%%CUR_SS%
echo Database dump terminated %TERMINATION_TIMESTAMP% >> %LOGFILE%