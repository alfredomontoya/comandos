@echo off
setlocal

>nul 2>&1 net session || (
    echo Re-lanzando como Administrador...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c', '%~f0' -Verb RunAs"
    exit /b
)

echo ==================================================================
echo ***** DESINSTALAR PROGRAMAS MICROSTATION / BENTLEY *****
echo Programas instalados relacionados con MicroStation / Bentley:
echo ==================================================================
echo.

set "PS1=%TEMP%\bentley_%RANDOM%.ps1"

(
echo $paths = @(
echo     'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
echo     'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
echo     'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
echo ^)
echo $found = @(^)
echo foreach ($p in $paths^) {
echo     Get-ItemProperty $p -Name DisplayName, Publisher, UninstallString, QuietUninstallString, ModifyPath, ProductCode -ErrorAction SilentlyContinue ^|
echo         Where-Object { ^($_.DisplayName -match 'microstation^|bentley'^) -or ^($_.Publisher -match 'microstation^|bentley'^) } ^|
echo         ForEach-Object { $idx = $found.Count + 1; $found += $_; Write-Host ^("{0,2}. {1,-55} {2}" -f $idx, $_.DisplayName, $_.Publisher^) }
echo }
echo if ($found.Count -gt 0^) {
echo     Write-Host "`n------------------------------------------------------------"
echo     $resp = Read-Host "Desea desinstalar TODOS estos programas? (S/N)"
echo     if ($resp -eq 'S' -or $resp -eq 's'^) {
echo         for ^($i = 0; $i -lt $found.Count; $i++^) {
echo             $prog = $found[$i]
echo             $nro = $i + 1
echo             Write-Host "`n[$nro] Desinstalando: $($prog.DisplayName)..."
echo             $uninst = $prog.UninstallString
echo             if ^(-not $uninst^) { $uninst = $prog.QuietUninstallString }
echo             if ^(-not $uninst^) { $uninst = $prog.ModifyPath }
echo             if ^(-not $uninst^) {
echo                 $code = $prog.ProductCode
echo                 if ^(-not $code^) { $code = $prog.PSChildName }
echo                 if ($code^) {
echo                     if ($code -notmatch '^\{'^) { $code = "{$code}" }
echo                     $uninst = "MsiExec.exe /X$code"
echo                 }
echo             }
echo             if ^(-not $uninst^) {
echo                 $name2 = $prog.DisplayName -replace '[®™©]',''
echo                 Get-ChildItem 'HKLM:\Software\Classes\Installer\Products' -ErrorAction SilentlyContinue ^|
echo                     ForEach-Object {
echo                         $dn = ^(Get-ItemProperty $_.PSPath -Name ProductName -ErrorAction SilentlyContinue^).ProductName
echo                         $dn2 = $dn -replace '[®™©]',''
echo                         if ($dn -and ($dn2 -eq $name2 -or $dn2 -match [regex]::Escape^($name2^)^)^) {
echo                             $s = $_.PSChildName
echo                             $g1 = $s.Substring^(0,8^); $g2 = $s.Substring^(8,4^); $g3 = $s.Substring^(12,4^)
echo                             $g4 = $s.Substring^(16,4^); $g5 = $s.Substring^(20,12^)
echo                             $rev1 = $g1.Substring^(6,2^) + $g1.Substring^(4,2^) + $g1.Substring^(2,2^) + $g1.Substring^(0,2^)
echo                             $rev2 = $g2.Substring^(2,2^) + $g2.Substring^(0,2^)
echo                             $rev3 = $g3.Substring^(2,2^) + $g3.Substring^(0,2^)
echo                             $guidStr = "{$rev1-$rev2-$rev3-$g4-$g5}"
echo                             $uninst = "msiexec.exe /x $guidStr"
echo                         }
echo                     }
echo             }
echo             if ^($uninst -ilike '*msiexec*'^) {
echo                 if ^($uninst -match '/[Ii]'^) { $uninst = $uninst -replace '/[Ii]','/X' }
echo                 $uninst += ' /quiet'
echo             }
echo             if ^($uninst^) {
echo                 Remove-ItemProperty -LiteralPath $prog.PSPath -Name NoRemove -ErrorAction SilentlyContinue
echo                 Write-Host "  Comando: $uninst"
echo                 cmd /c $uninst
echo             } else {
echo                 Write-Host "  (sin comando de desinstalacion)"
echo             }
echo         }
echo     } else { Write-Host "Operacion cancelada." }
echo } else {
echo     Write-Host "No se encontraron programas."
echo }
echo Write-Host "`nPresione Enter para salir..."
echo Read-Host
) > "%PS1%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del "%PS1%" 2>nul
