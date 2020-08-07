param(
    [Switch]$InstallUtilityBelt,
    [Switch]$Install,
    [Switch]$Uninstall,
    [Switch]$Reinstall,
    [Switch]$PreserveUserDefinedCommands
    )
if (!$Install -and !$Uninstall -and !$Reinstall -and !$InstallUtilityBelt) {
    Get-Content .\Readme.md -Raw
}

$QuickForceText = if ($Reinstall) { '-force' } else { '' }

if ($Uninstall) {
    . ".\Uninstall-Script.ps1" -PreserveUserDefinedCommands $PreserveUserDefinedCommands
}

if ($Install -or $Reinstall) {
    Invoke-Expression ".\Install-Script.ps1 $QuickForceText"
}

if ($InstallUtilityBelt) {
    . ".\Install-UtilityBelt.ps1"
}