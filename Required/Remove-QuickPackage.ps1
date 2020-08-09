function global:Remove-QuickPackage {
    param(
        [Switch]$PreserveUserDefinedCommands,
        [Switch]$Force
    )

    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$PSScriptRoot\Reserved\Remove-FolderIfExists.ps1"
    . "$PSScriptRoot\Remove-QuickUtilityBelt.ps1"

    $QuickForceText = if ($force) { '-force' } else {''}

    $PowershellModuleRoot = Split-Path $QuickPowershellModulePath
    if (Test-Path $PowershellModuleRoot) {
        Invoke-Expression "Remove-FolderIfExists $QuickHelpersRoot $QuickForceText"
        
        if ($PreserveUserDefinedCommands) {
            Remove-QuickUtilityBelt

            if (Test-Path $QuickPowershellModulePath) {
                Remove-Item $QuickPowershellModulePath
            }
        } else {
            Invoke-Expression "Remove-FolderIfExists (Split-Path $QuickPowershellModulePath) $QuickForceText"
        }   
    }

    if (Test-Path $QuickPowershellUserProfileRoot) {
        $userProfiles = Get-ChildItem $QuickPowershellUserProfileRoot -Filter '*profile.ps1'
        foreach($userProfile in $userProfiles) {
            (Get-Content $QuickPowershellUserProfileRoot\$userProfile -Raw) -replace 'Import-Module Quick-Package', '' | Out-File $QuickPowershellUserProfileRoot\$userProfile
        }
    }
}