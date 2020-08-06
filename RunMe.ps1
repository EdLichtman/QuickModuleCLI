param(
    [Switch]$InstallUtilityBelt,
    [Switch]$Force,
    [Switch]$Install,
    [Switch]$Uninstall,
    [Switch]$Reinstall

    )
if (!$Install -and !$Uninstall -and !$Reinstall) {
    Get-Content .\Readme.md -Raw
}

if ($Uninstall -or $Reinstall) {
    . ".\Uninstall-Script.ps1"
}

if ($Install -or $Reinstall) {
    . ".\Install-Script.ps1" -InstallUtilityBelt $InstallUtilityBelt -Force $Force
}