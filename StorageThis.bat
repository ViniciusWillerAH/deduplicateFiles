@echo off
( fsutil hardlink list "%~f1" | findstr /R /B /c:\\STORAGE\\20220514170551\\[0-9a-fA-F][0-9a-fA-F]\\[0-9a-fA-F][0-9a-fA-F]\\[0-9a-fA-F]*_[0-9a-fA-F]*_[0-9a-fA-F]*_[0-9]*  && goto EOF && goto :EOF  ) 1>nul 2>nul

rem ###################################################################################################################################################################################################################

SetLocal EnableDelayedExpansion
set Variables=/c:"Variables"
for /F "delims==" %%a in ('set') do set Variables= !Variables! /c:"%%a"
rem echo %Variables%


rem ###################################################################################################################################################################################################################

rem echo not ready & goto :EOF
set exitmessage=not enough parameters
if "a%~1" == "a" echo usage:StorageThis.bat ^<file address^>  && goto EOF && goto :EOF
if not exist "%~1" echo "%~1" doesnt exist & goto :EOF
dir "%~1*" /a:-d /b 1>NUL 2>NUL
if not %errorlevel% == 0 echo "%~1" is a Directory not ^<file address^>  && goto EOF && goto :EOF
dir "%~1\." /b 1>NUL 2>NUL
if %errorlevel% == 0 echo "%~1" is a Directory not ^<file address^> && goto EOF && goto :EOF
dir "%~f1" /a:l /b 1>NUL 2>NUL
if %errorlevel% == 0 echo "%~f1" is SoftLink & goto EOF & goto :EOF 

if "%~x1" == ".STORAGETHIS" echo i refuse "%~f1" & goto EOF & goto :EOF 

if "%~z1" == "0" echo zero length, gtfo "%~f1" & goto EOF & goto :EOF 

setlocal
set log=init

@(set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%&if /I %time:~0,2% LSS 10 (set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%0%time:~1,1%%time:~3,2%%time:~6,2%))

rem ###################################################################################################################################################################################################################
@echo off

md B:\LOGS >nul 2>nul
set SizeOfFile=%~z1
:fillZeroes
set SizeOfFile=0%SizeOfFile%
if "%SizeOfFile:~10,1%" == "" goto fillZeroes
echo "%~f1">>"B:\LOGS\S\%SizeOfFile%.txt"

rem ###################################################################################################################################################################################################################

@echo off
set exitmessage=hashfile error
for /f "delims=*" %%a in ('hashfile /set /round /Round "%~f1"') do set F_%%a
rem if /i 0%errorlevel% NEQ 0 goto EOF_ERR
set exitmessage=hashfile define Failed
for %%a in ( F_CRC32_CLS F_CRC32_SUM F_FILE F_MD5 F_SHA1 F_SHA256 F_SIZE F_SUM ) do if not defined %%a ( echo undefined "%%a" & goto EOF_ERR )

rem #### Gen [semi] unique MD5 code and create a folder if not exist, if exist compareFiles
for /f "delims=*" %%a in ('echo %F_MD5:~0,4%^| sed "s/.\{2\}/&\\/g"') do set storFolder=%%a
set destinationFilename=\STORAGE\20220514170551\%storFolder%%F_MD5%_%F_SHA1%_%f_SHA256%_%F_CRC32_CLS%

echo %destinationFilename%*%F_FILE%*%F_CRC32_CLS%*%F_CRC32_SUM%*%F_CRC32%*%F_MD5%*%F_SHA1%*%F_SHA256%*%F_SIZE%*%F_SUM%*%timestamp%*"%~t1"*%~z1*%~a1>> a:\DB\filehashes_20220514170551.list
echo %destinationFilename%*%F_FILE%*%F_CRC32_CLS%*%F_CRC32_SUM%*%F_CRC32%*%F_MD5%*%F_SHA1%*%F_SHA256%*%F_SIZE%*%F_SUM%*%timestamp%*"%~t1"*%~z1*%~a1>>  "\STORAGE\index_20220514170551.txt"

md "%~d1\STORAGE\20220514170551\%storFolder%" >nul 2>nul

set log=%log% ; hashed

:tryagainnospace
if not exist "%~d1%destinationFilename%" for /f "tokens=1-9" %%a in ('dir \ ^| findstr /c:"bytes free" ^| tr -d ",."') do ( if %%c lss 10000000 echo There is no Enough space in disk & title PAUSED: NO SPACE ENOUGH %%c / 1000000 && pause & goto tryagainnospace )

( fsutil hardlink list "%~f1"| findstr /i /c:"%destinationFilename%" && goto EOF ) 1>nul 2>nul

rem echo %F_CRC32_CLS% %F_CRC32_SUM% %F_CRC32% %F_MD5% %F_SHA1% %F_SHA256% %F_SIZE%	%F_SUM%	%F_FILE%
rem echo "%destinationFilename%" "%~p1" "%~n1" "%~x1" "" "%~z1" "%timestamp%"

rem echo -
rem echo A "%~f1"
rem echo B "%~pn1_%timestamp%%~x1"
rem echo C "%destinationFilename%"
rem echo -
rem echo.
rem pause
@echo off
rem ###################################################################################################################################################################################################################

set log=%log% ; 0
if not exist "%~f1" set log=%log%.
if     exist "%~f1" set log=%log%E
if not exist "%~d1%destinationFilename%" set log=%log%.
if     exist "%~d1%destinationFilename%" set log=%log%S
if not exist "%~f1.STORAGETHIS" set log=%log%.
if     exist "%~f1.STORAGETHIS" set log=%log%B

rem ###################################################################################################################################################################################################################


if exist "%~f1.STORAGETHIS" (
	set log=%log% ; backupNameExistAlready
	goto EOF_ERR
)
if exist "%~d1%destinationFilename%" (
   set log=%log% ; renameOriginalFile
   move "%~f1" "%~f1.STORAGETHIS"
)
if exist "%~d1%destinationFilename%" set log=%log% ; storageExists
if not exist "%~d1%destinationFilename%" set log=%log% ; hardlinking
(
  mklink /H "%~d1%destinationFilename%" "%~f1"
  mklink /H "%~f1" "%~d1%destinationFilename%"
  @compact /C /S /A /I /F /Q /EXE:LZX "%~d1%destinationFilename%"
  rem @attrib +R +A +H "%~d1%destinationFilename%" >nul 2>nul
) >nul 2>nul

set exitmessage=mklink fail on destinationFilename: %~d1%destinationFilename%

rem ###################################################################################################################################################################################################################

set log=%log% ; 1
if not exist "%~f1" set log=%log%.
if     exist "%~f1" set log=%log%E
if not exist "%~d1%destinationFilename%" set log=%log%.
if     exist "%~d1%destinationFilename%" set log=%log%S
if not exist "%~f1.STORAGETHIS" set log=%log%.
if     exist "%~f1.STORAGETHIS" set log=%log%B

rem ###################################################################################################################################################################################################################

if not exist "%~f1" (
    set log=%log% ; Ori_File_Gone
    move "%~f1.STORAGETHIS" "%~f1"
	if exist "%~f1" (
		set log=%log% ; Ori_File_Restored
		echo SOMETHING GONE WRONG
		set exitmessage=Something failed and restored the file "%~f1"
		goto EOF_ERR
	)
    echo SOMETHING GONE WRONG
    set exitmessage=original file is gone. i fucked up "%~f1"
    goto EOF_ERR
)

if not exist "%~d1%destinationFilename%" (
    set log=%log% ; stor_seems_inexistent
    move "%~f1.STORAGETHIS" "%~f1"
    echo SOMETHING GONE WRONG
    set exitmessage=hashed file did not hardlink, wtf "%~f1"
    goto EOF_ERR
)

if exist "%~f1" if exist "%~d1%destinationFilename%" if exist "%~f1.STORAGETHIS" (
    set log=%log% ; ori_file_bkp_exist
    move "%~f1.STORAGETHIS" "%~f1"
    del "%~f1.STORAGETHIS" >nul 2>nul
	if not exist \tmp md \tmp
    move "%~f1.STORAGETHIS" \tmp\ >nul 2>nul
)

if exist "%~f1" if exist "%~f1.STORAGETHIS" (
	set log=%log% ; both_file_exist_wtf
    set exitmessage=now there is multiple of them "%~f1"
    goto EOF_ERR
)

(
rem attrib +R "%~f1"
rem icacls "%~f1" /inheritance:r /grant:r Everyone:R
rem attrib +R "%~d1%destinationFilename%"
rem icacls "%~d1%destinationFilename%" /inheritance:r /grant:r Everyone:R
) > nul

set log=%log% ; 3
if not exist "%~f1" set log=%log%.
if     exist "%~f1" set log=%log%E
if not exist "%~d1%destinationFilename%" set log=%log%.
if     exist "%~d1%destinationFilename%" set log=%log%S
if not exist "%~f1.STORAGETHIS" set log=%log%.
if     exist "%~f1.STORAGETHIS" set log=%log%B

goto EOF_DONE

:EOF_ERR

set log=%log% ; 2
if not exist "%~f1" set log=%log%.
if     exist "%~f1" set log=%log%E
if not exist "%~d1%destinationFilename%" set log=%log%.
if     exist "%~d1%destinationFilename%" set log=%log%S
if not exist "%~f1.STORAGETHIS" set log=%log%.
if     exist "%~f1.STORAGETHIS" set log=%log%B


echo [1;31mError[0m, Failure
set | findstr /v %Variables%
@(@echo ###################### & set) >> B:\LOGS\StorageThis_20220514170551.log

endlocal
rem pause
goto :EOF

rem ###################################################################################################################################################################################################################

:EOF_DONE
echo %log%
echo Input File:	"[1;32m%~f1[0m"
echo Storage File:	"[1;36m%~d1%destinationFilename%[0m"
rem attrib +R "%~d1%destinationFilename%"
rem attrib +R "%~f1"
endlocal & set storagefile=%destinationFilename%

:EOF
if defined exit exit