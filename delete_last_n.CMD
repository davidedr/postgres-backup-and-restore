dir /b *.databasedump.log
for /f "delims=, skip=10" %f in ('dir /b *.databasedump.log') do dir %f
for /f "delims=, skip=10" %f in ('dir /b *.databasedump.log') do del %f
