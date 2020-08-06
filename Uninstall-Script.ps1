$localHelpersPath = ".\Required"
. $localHelpersPath\Get-UDPowershellEnvironment.ps1

$PowershellModuleRoot = Split-Path $PowershellModulePath
if (Test-Path $PowershellModuleRoot) {
    Remove-Item $PowershellModuleRoot -Recurse
}
if (Test-Path $PowershellProfilePath) {
    (Get-Content $PowershellProfilePath -Raw) -replace 'Import-Module UDFunction-Builder', '' | Out-File $PowershellProfilePath
}