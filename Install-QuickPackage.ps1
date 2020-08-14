function Install-QuickPackage {
    param(
        [Switch]$InstallUtilityBelt,
        [Switch]$InstallUtility,
        [Switch]$Install,
        [Switch]$Uninstall,
        [Switch]$Reinstall,
        [Switch]$PreserveUserDefinedCommands
    )

    $ReservedRoot = "$PSScriptRoot\Required\Reserved"
    Invoke-Expression ". '$ReservedRoot\Installer\Add-QuickPackage.ps1'"
    Invoke-Expression ". '$PSScriptRoot\Required\Add-QuickUtility.ps1'"
    Invoke-Expression ". '$PSScriptRoot\Required\Add-QuickPackageToProfile.ps1'"
    Invoke-Expression ". '$PSScriptRoot\Required\Remove-QuickPackage.ps1'"
    Invoke-Expression ". '$PSScriptRoot\Required\Remove-QuickUtilityBelt.ps1'"
    if (Exit-AfterImport) {
        Test-ImportCompleted
        return;
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
        Add-QuickUtility -InstallEntireBelt:$InstallUtilityBelt -Force:$Reinstall
    }
}