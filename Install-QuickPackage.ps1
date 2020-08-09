function Install-QuickPackage {
    param(
        [Switch]$InstallUtilityBelt,
        [Switch]$InstallUtility,
        [Switch]$Install,
        [Switch]$Uninstall,
        [Switch]$Reinstall,
        [Switch]$PreserveUserDefinedCommands
    )
    if (
        !(Test-Path Variable:\$UnderTest) `
            -or ($UnderTest -eq $False) `
            -or ((Test-Path Variable:\$UnderTest) -and ($ValidatingImports -eq $true))
        ) {
        $ReservedRoot = "$PSScriptRoot\Required\Reserved"
        . "$ReservedRoot\Installer\Add-QuickPackage.ps1"
        . "$PSScriptRoot\Required\Add-QuickUtility.ps1"
        . "$PSScriptRoot\Required\Add-QuickPackageToProfile.ps1"
        . "$PSScriptRoot\Required\Remove-QuickPackage.ps1"
        . "$PSScriptRoot\Required\Remove-QuickUtilityBelt.ps1"
        if ($ValidatingImports -eq $true) {
            return;
        }
    }

    if (!$Install -and !$Uninstall -and !$Reinstall -and !$InstallUtilityBelt -and !$InstallUtility -and !$AddToProfile) {
        Write-Output 'Help Documentation WIP'
    }
    
    if ($Uninstall -or $Reinstall) {
        Remove-QuickUtilityBelt
        Remove-QuickPackage -PreserveUserDefinedCommands:$PreserveUserDefinedCommands -Force:$Reinstall
    }
    
    if ($Install -or $Reinstall) {
        Add-QuickPackage -Force:$Reinstall
        Add-QuickPackageToProfile
    }
    
    if ($InstallUtilityBelt -or $InstallUtility) {
        Add-QuickUtility -InstallEntireBelt:$InstallEntireBelt -Force:$Reinstall
    }
}