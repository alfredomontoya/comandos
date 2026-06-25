@echo off
setlocal enabledelayedexpansion

>nul 2>&1 net session || (
    echo Re-lanzando como Administrador...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c', '%~f0' -Verb RunAs -Wait"
    exit /b
)

cls
echo =====================================================
echo   ACTUALIZAR CONTRASENA DE ADMINISTRADOR
echo =====================================================
echo.
echo Usuarios locales:
echo =================

set COUNT=0
where wmic >nul 2>&1
if !ERRORLEVEL! equ 0 (
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
) else (
    for /f "skip=4 delims=" %%a in ('net user') do (
        echo %%a | findstr /B /C:"---" >nul
        if !ERRORLEVEL! neq 0 (
            for %%b in (%%a) do (
                set /a COUNT+=1
                set "USER!COUNT!=%%b"
                echo [!COUNT!] %%b
            )
        )
    )
)

if !COUNT! equ 0 (
    echo No se encontraron usuarios locales.
    pause
    exit /b
)

echo.
set /p OPC="Seleccionar nro de usuario: "
if "%OPC%"=="0" exit /b
if "%OPC%"=="" exit /b

set "USUARIO=!USER%OPC%!"
if not defined USUARIO (
    echo Numero invalido.
    pause
    exit /b
)

echo.
echo Cambiando contrasena de %USUARIO% a ******...
net user "%USUARIO%" "S3cr3t4*"
if !ERRORLEVEL! equ 0 (
    echo OK: Contrasena de %USUARIO% actualizada a ******.
) else (
    echo ERROR: No se pudo cambiar la contrasena.
    echo        Verifique que la cuenta exista y este habilitada.
)
echo.
pause
