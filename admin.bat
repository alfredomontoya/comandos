@echo off
setlocal enabledelayedexpansion

>nul 2>&1 net session || (
    echo Re-lanzando como Administrador...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c', '%~f0' -Verb RunAs"
    exit /b
)

cls
echo Usuarios del grupo Administradores:
echo ===================================
echo.

set COUNT=0
for /f "tokens=* skip=6" %%a in ('net localgroup Administradores 2^>nul') do (
    set "linea=%%a"
    if "!linea!"=="" goto :mostrar
    if "!linea!"=="Se ha completado el comando correctamente." goto :mostrar
    if "!linea!"=="The command completed successfully." goto :mostrar
    set /a COUNT+=1
    set "USER!COUNT!=%%a"
    echo [!COUNT!] %%a
)

:mostrar
if %COUNT% equ 0 (
    echo No hay usuarios en el grupo Administradores.
    pause
    exit /b
)

echo.
set OPC=
set /p OPC="Seleccione numero a quitar (0=salir): "

if "%OPC%"=="0" exit /b
if "%OPC%"=="" exit /b

set "USUARIO=!USER%OPC%!"
if "%USUARIO%"=="" (
    echo Numero invalido.
    pause
    exit /b
)

echo.
echo Quitando a %USUARIO% del grupo Administradores...
net localgroup Administradores "%USUARIO%" /delete
if %errorlevel% equ 0 (
    echo OK: %USUARIO% removido.
) else (
    echo ERROR: No se pudo quitar a %USUARIO%.
)
echo.
pause
