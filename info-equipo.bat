@echo off
setlocal enabledelayedexpansion

set "ARCHIVO=info-equipo-%COMPUTERNAME%.txt"

(
echo ========================================
echo       INFORMACION DEL EQUIPO
echo ========================================
echo.
) > "%ARCHIVO%"

where wmic >nul 2>nul

if %errorlevel% equ 0 (
    echo NOMBRE DEL EQUIPO: %COMPUTERNAME% >> "%ARCHIVO%"

    for /f "skip=1 delims=" %%a in ('wmic csproduct get name') do for /f "delims=" %%b in ("%%a") do echo MODELO: %%b >> "%ARCHIVO%"
    for /f "skip=1 delims=" %%a in ('wmic bios get serialnumber') do for /f "delims=" %%b in ("%%a") do echo SERIE: %%b >> "%ARCHIVO%"
    for /f "skip=1 delims=" %%a in ('wmic cpu get name') do for /f "delims=" %%b in ("%%a") do echo PROCESADOR: %%b >> "%ARCHIVO%"
    for /f "skip=1 delims=" %%a in ('wmic memorychip get capacity') do for /f "delims=" %%b in ("%%a") do echo MEMORIA ^(por modulo^): %%b bytes >> "%ARCHIVO%"
    for /f "skip=1 delims=" %%a in ('wmic computersystem get TotalPhysicalMemory') do for /f "delims=" %%b in ("%%a") do if not "%%b"=="" powershell -noprofile -command "$val=[math]::Round(%%b/1GB,2); Write-Output \"MEMORIA TOTAL: $val GB\"" >> "%ARCHIVO%"
    for /f "skip=1 delims=" %%a in ('wmic diskdrive get model') do for /f "delims=" %%b in ("%%a") do echo DISCO: %%b >> "%ARCHIVO%"
    for /f "skip=1 delims=" %%a in ('wmic path win32_videocontroller get name') do for /f "delims=" %%b in ("%%a") do echo VIDEO: %%b >> "%ARCHIVO%"
) else (
    set "PS_FILE=%TEMP%\info-equipo.ps1"

    > "%PS_FILE%" echo $Archivo = "%ARCHIVO%"
    >> "%PS_FILE%" echo $Info = @{}
    >> "%PS_FILE%" echo $Info["NOMBRE DEL EQUIPO"] = $env:COMPUTERNAME
    >> "%PS_FILE%" echo $Info["MODELO"] = ^(Get-CimInstance Win32_ComputerSystemProduct^).Name
    >> "%PS_FILE%" echo $Info["SERIE"] = ^(Get-CimInstance Win32_BIOS^).SerialNumber
    >> "%PS_FILE%" echo $Info["PROCESADOR"] = ^(Get-CimInstance Win32_Processor^).Name
    >> "%PS_FILE%" echo $Info["MEMORIA ^(por modulo^)"] = ^(^(Get-CimInstance Win32_PhysicalMemory^) ^| ForEach-Object { "$($_.Capacity) bytes" }^) -join "; "
    >> "%PS_FILE%" echo $Info["MEMORIA TOTAL"] = "{0:N2} GB" -f ^(^(Get-CimInstance Win32_ComputerSystem^).TotalPhysicalMemory / 1GB^)
    >> "%PS_FILE%" echo $Info["DISCO"] = ^(^(Get-CimInstance Win32_DiskDrive^) ^| ForEach-Object { $_.Model }^) -join "; "
    >> "%PS_FILE%" echo $Info["VIDEO"] = ^(Get-CimInstance Win32_VideoController^).Name
    >> "%PS_FILE%" echo "========================================" ^| Out-File $Archivo
    >> "%PS_FILE%" echo $Info.Keys ^| ForEach-Object { "$($_): $($Info[$_])" } ^| Out-File $Archivo -Append

    powershell -ExecutionPolicy Bypass -File "%PS_FILE%"
    del "%PS_FILE%"
)

echo. >> "%ARCHIVO%"
echo Archivo generado: %ARCHIVO% >> "%ARCHIVO%"

set "JSON_PS=%TEMP%\info-equipo-json.ps1"

> "%JSON_PS%" echo $serie = ^(Get-CimInstance Win32_BIOS^).SerialNumber
>> "%JSON_PS%" echo $nombre = $env:COMPUTERNAME
>> "%JSON_PS%" echo $procesador = ^(Get-CimInstance Win32_Processor^).Name
>> "%JSON_PS%" echo $memoria = "{0:N2} GB" -f ^(^(Get-CimInstance Win32_ComputerSystem^).TotalPhysicalMemory / 1GB^)
>> "%JSON_PS%" echo $discos = ^(^(Get-CimInstance Win32_DiskDrive^).Model^) -join "; "
>> "%JSON_PS%" echo $videos = ^(^(Get-CimInstance Win32_VideoController^).Name^) -join "; "
>> "%JSON_PS%" echo $modelo = ^(Get-CimInstance Win32_ComputerSystemProduct^).Name
>> "%JSON_PS%" echo $descripcion = "Procesador: $procesador`nMemoria: $memoria`nDiscos: $discos`nVideo: $videos"
>> "%JSON_PS%" echo $json = @{
>> "%JSON_PS%" echo     serie = $serie
>> "%JSON_PS%" echo     codigo_alcaldia = $serie
>> "%JSON_PS%" echo     nombre = $nombre
>> "%JSON_PS%" echo     modelo = $modelo
>> "%JSON_PS%" echo     descripcion = $descripcion
>> "%JSON_PS%" echo } ^| ConvertTo-Json
>> "%JSON_PS%" echo $json ^| Out-File -FilePath "info-equipo-%COMPUTERNAME%.json" -Encoding utf8

powershell -ExecutionPolicy Bypass -File "%JSON_PS%"
del "%JSON_PS%"

echo.
echo Informacion guardada en: %ARCHIVO%
echo.
pause
