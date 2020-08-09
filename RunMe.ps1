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
. "$PSScriptRoot\Required\Add-QuickUtility.ps1"
. "$PSScriptRoot\Add-QuickPackageToProfile.ps1"
. "$PSScriptRoot\Required\Remove-QuickPackage.ps1"
. "$PSScriptRoot\Required\Remove-QuickUtilityBelt.ps1"

$QuickForceText = if ($Reinstall) { '-force' } else { '' }
$PreserveUserDefinedCommandsText = if ($PreserveUserDefinedCommands) { '-PreserveUserDefinedCommands' } else { '' }

if ($Uninstall -or $Reinstall) {
    Remove-QuickUtilityBelt
    Invoke-Expression "Remove-QuickPackage $PreserveUserDefinedCommandsText $QuickForceText"
}

if ($Install -or $Reinstall) {
    Invoke-Expression "$ReservedRoot\Installer\Install-Script.ps1 $QuickForceText"
    Add-QuickPackageToProfile
}

if ($InstallUtilityBelt -or $InstallUtility) {
    $InstallEntireBelt = if ($InstallUtilityBelt) { '-InstallEntireBelt' } else { '' }
    Invoke-Expression "Add-QuickUtility $InstallEntireBelt $QuickForceText"
}