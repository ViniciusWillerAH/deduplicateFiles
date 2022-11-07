@echo off
if not exist "%~1" ( echo the path doesnt exist && goto :EOF && goto EOF )
call :nextdir "%~1" 2>nul
goto :EOF
goto EOF
:nextdir

for %%a in (
	log temp tmp Sysmon STORAGE "System Volume Information" AppCache Application Cache cache2 Caches CacheStorage Code D3DSCache GPUCache GrShaderCache INetCache jumpListCache optimization_guide_hint_cache_store ScriptCache shader-cache ShaderCache shadercache startupCache
) do if "%%~a" == "%~nx1" goto :EOF

rem title "%~f0" "%~f1"
rem  "%~nx0" "%~f1"
for /f "delims=*" %%a in ('dir "%~1" /b /a:d-h-l') do cmd.exe /C""%~f0" "%~1\%%a"
for /f "delims=*" %%a in ('dir "%~1" /b /a:dh-l') do cmd.exe /C""%~f0" "%~1\%%a"
for /f "delims=*" %%a in ('dir "%~1" /b /a:-d-h-l-r') do @( @StorageThis.bat "%~f1\%%a" )
for /f "delims=*" %%a in ('dir "%~1" /b /a:h-d-l-r') do @( @StorageThis.bat "%~f1\%%a" )