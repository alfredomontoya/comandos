@echo off
setlocal enabledelayedexpansion

>nul 2>&1 net session || (
    echo Re-lanzando como Administrador...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c', '%~f0' -Verb RunAs"
    exit /b
)

cls
echo Usuarios locales:
echo =================
echo.

set COUNT=0
for /f "skip=1 delims=" %%a in ('wmic useraccount where "localaccount=true" get name 2^>nul') do (
    for /f "delims=" %%b in ("%%a") do (
        set "usr=%%b"
        if not "!usr!"=="" (
            for /l %%t in (1,1,32) do if "!usr:~-1!"==" " set "usr=!usr:~0,-1!"
            set /a COUNT+=1
            set "USER!COUNT!=!usr!"
            echo [!COUNT!] !usr!
        )
    )
)

if %COUNT% equ 0 (
    echo No se encontraron usuarios locales.
    pause
    exit /b
)

echo.
set OPC=
set /p OPC="Seleccione numero (0=salir): "
if "%OPC%"=="0" exit /b
if "%OPC%"=="" exit /b

set "USUARIO=!USER%OPC%!"
if "%USUARIO%"=="" (
    echo Numero invalido.
    pause
    exit /b
)

echo.
echo Cambiando contrasena de %USUARIO% a ******...
net user "%USUARIO%" "S3cr3t4*"
if %errorlevel% equ 0 (
    echo OK: Contrasena de %USUARIO% actualizada a ******.
) else (
    echo ERROR: No se pudo cambiar la contrasena.
)
echo.
pause
