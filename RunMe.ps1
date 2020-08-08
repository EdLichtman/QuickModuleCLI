param(
    [Switch]$InstallUtilityBelt,
    [Switch]$InstallUtility,
    [Switch]$Install,
    [Switch]$Uninstall,
    [Switch]$Reinstall,
    [Switch]$PreserveUserDefinedCommands
    )

if (!$Install -and !$Uninstall -and !$Reinstall -and !$InstallUtilityBelt -and !$InstallUtility -and !$AddToProfile) {
    Get-Content .\Readme.md -Raw
}

$ReservedRoot = "$PSScriptRoot\Required\Reserved"

$QuickForceText = if ($Reinstall) { '-force' } else { '' }
$PreserveUserDefinedCommandsText = if ($PreserveUserDefinedCommands) { '-PreserveUserDefinedCommands' } else { '' }
$AddToProfileText = if ($AddToProfile) { '-AssociateProfile' } else { '' }

if ($Uninstall -or $Reinstall) {
    Invoke-Expression "$ReservedRoot\Uninstall-Script.ps1 $PreserveUserDefinedCommandsText"
}

if ($Install -or $Reinstall) {
    Invoke-Expression "$ReservedRoot\Install-Script.ps1 $QuickForceText"
}

if ($InstallUtilityBelt -or $InstallUtility) {
    $InstallEntireBelt = if ($InstallUtilityBelt) { '-InstallEntireBelt' } else { '' }
    Invoke-Expression "$ReservedRoot\Install-UtilityBelt.ps1 $InstallEntireBelt $QuickForceText"
}