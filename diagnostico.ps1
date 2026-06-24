$nombres = @('DgnDb', 'V8i', 'RealDWG', 'Autodesk')
$paths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')

Write-Host '=== Valores del registro de esos programas ==='
foreach ($p in $paths) {
    Get-ItemProperty $p -ErrorAction SilentlyContinue | Where-Object {
        $nombre = $_.DisplayName
        $encontrado = $false
        foreach ($n in $nombres) { if ($nombre -match $n) { $encontrado = $true } }
        $encontrado
    } | Format-List DisplayName, Publisher, UninstallString, QuietUninstallString, ModifyPath, ProductCode, SystemComponent, NoRemove
}

Write-Host '--- MSI COM disponible? ---'
try {
    $msi = New-Object -ComObject WindowsInstaller.Installer
    $prods = $msi.ProductsEx('', '', 7)
    Write-Host ("SI - Productos MSI: " + $prods.Count)
    foreach ($p in $prods) {
        $pn = $p.InstallProperty(3)
        $pc = $p.ProductCode
        if ($pn -match 'Bentley|MicroStation|Autodesk|DgnDb|RealDWG|HDR') {
            Write-Host ("  " + $pn + "  ->  " + $pc)
        }
    }
} catch { Write-Host ("NO - " + $_.Exception.Message) }

Write-Host '--- HKCR\Installer\Products (Bentley) ---'
$found = $false
Get-ChildItem 'HKLM:\Software\Classes\Installer\Products' -ErrorAction SilentlyContinue | ForEach-Object {
    $dn = (Get-ItemProperty $_.PSPath -Name ProductName -ErrorAction SilentlyContinue).ProductName
    if ($dn -match 'Bentley|MicroStation|Autodesk|DgnDb|RealDWG|HDR') {
        $found = $true
        Write-Host ("  " + $_.PSChildName)
        Write-Host ("    ProductName: " + $dn)
    }
}
if (-not $found) { Write-Host '  (no se encontraron)' }

Read-Host 'Presione Enter para salir'
