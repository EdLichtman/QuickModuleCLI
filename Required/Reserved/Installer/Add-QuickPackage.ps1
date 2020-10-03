function Add-QuickPackage {
    param(
        [Switch] $Force
    )

    $localHelpersPath = "$PSScriptRoot\..\.."
    $localReservedHelpersPath = "$localHelpersPath\Reserved"
    $localUtilityBeltFunctionsPath = "$localReservedHelpersPath\UtilityBelt\Functions"
    $localUtilityBeltAliasesPath = "$localReservedHelpersPath\UtilityBelt\Aliases"
    
    . "$localReservedHelpersPath\Get-QuickEnvironment.ps1"
    . "$localReservedHelpersPath\New-FolderIfNotExists.ps1"
    . "$localReservedHelpersPath\New-FileWithContent.ps1"
    . "$localReservedHelpersPath\Copy-QuickFolderWithWarning.ps1"
    
    New-FolderIfNotExists $QuickPowershellUserProfileRoot
    New-FolderIfNotExists $QuickFunctionsRoot
    New-FolderIfNotExists $QuickAliasesRoot
    New-FolderIfNotExists $QuickHelpersRoot
    New-FolderIfNotExists $QuickUtilityBeltFunctionsRoot
    New-FolderIfNotExists $QuickUtilityBeltAliasesRoot
    New-FolderIfNotExists (Split-Path $QuickConfigurationsFile)
    
    Copy-QuickFolderWithWarning $localHelpersPath $QuickHelpersRoot 
    Copy-QuickFolderWithWarning $localReservedHelpersPath $QuickReservedHelpersRoot
    Copy-QuickFolderWithWarning $localUtilityBeltFunctionsPath $QuickUtilityBeltFunctionsRoot
    Copy-QuickFolderWithWarning $localUtilityBeltAliasesPath $QuickUtilityBeltAliasesRoot
    
    if ($Force -and (Test-Path $QuickPowershellModulePath)) {
        Remove-Item $QuickPowershellModulePath
    }
    if (!(Test-Path $QuickPowershellModulePath)) {
        Copy-Item "$PSScriptRoot\Quick-Package.psm1" $QuickPowershellModulePath 
    }
    
}
