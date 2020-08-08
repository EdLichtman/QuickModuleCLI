param(
    [Switch]$PreserveUserDefinedCommands
    )

. "$PSScriptRoot\Get-QuickEnvironment.ps1"
. "$PSScriptRoot\Remove-FolderIfExists.ps1"

$PowershellModuleRoot = Split-Path $QuickPowershellModulePath
if (Test-Path $PowershellModuleRoot) {
    Remove-FolderIfExists $QuickHelpersRoot
    
    if ($PreserveUserDefinedCommands) {
        $functions = Get-ChildItem $QuickFunctionsRoot
        foreach($function in $functions) {
            if (Get-Content $QuickFunctionsRoot\$function | Select-String $QuickUtilityBeltFunctionIdentifier) {
                Remove-Item "$QuickFunctionsRoot\$Function"
            }
        }
        
        $aliases = Get-ChildItem $QuickAliasesRoot
        foreach($alias in $aliases) {
            if (Get-Content $QuickAliasesRoot\$alias | Select-String $QuickUtilityBeltFunctionIdentifier) {
                Remove-Item "$QuickAliasesRoot\$alias"
            }
        }

        if (Test-Path $QuickPowershellModulePath) {
            Remove-Item $QuickPowershellModulePath
        }
    } else {
        Remove-FolderIfExists (Split-Path $QuickPowershellModulePath)
    }   
}
if (Test-Path $QuickPowershellUserProfileRoot) {
    $userProfiles = Get-ChildItem $QuickPowershellUserProfileRoot -Filter '*profile.ps1'
    foreach($userProfile in $userProfiles) {
        (Get-Content $QuickPowershellUserProfileRoot\$userProfile -Raw) -replace 'Import-Module Quick-Package', '' | Out-File $QuickPowershellUserProfileRoot\$userProfile
    }
}