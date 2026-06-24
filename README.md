# Comandos

Colección de herramientas de administración para Windows enfocadas en gestión de usuarios y desinstalación de software CAD (Bentley, MicroStation, Autodesk).

## Scripts

| Archivo | Descripción |
|---------|-------------|
| `remove-admin.bat` | Lista los usuarios del grupo Administradores, permite remover uno y vuelve a listar en bucle hasta que se presione 0. |
| `diagnostico.bat` | Lanza el script de diagnóstico PowerShell. |
| `diagnostico.ps1` | Busca en el registro programas Bentley, MicroStation, Autodesk y muestra información de desinstalación. |
| `pass.bat` | Lista usuarios locales y permite cambiar la contraseña del seleccionado. |
| `unistall-micro.bat` | Busca programas MicroStation/Bentley y los desinstala en lote (con elevación automática de admin). |
| `unistall-progra.bat` | Busca programas por texto recibido como parámetro y desinstala el seleccionado. |
