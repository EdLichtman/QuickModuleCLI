param(
    [Switch]$PreserveUserDefinedCommands
    )

$localHelpersPath = ".\Required"
. $localHelpersPath\Get-QuickEnvironment.ps1

$PowershellModuleRoot = Split-Path $QuickPowershellModulePath
if (Test-Path $PowershellModuleRoot) {
    if (Test-Path $QuickHelpersRoot) {
        Remove-Item $QuickHelpersRoot -Recurse
    }
    
    if ($PreserveUserDefinedCommands) {
        $UtilityBeltFunctions = Get-ChildItem ".\UtilityBelt\Functions"
        foreach($Function in $UtilityBeltFunctions) {
            if (Test-Path "$QuickFunctionsRoot\$Function") {
                Remove-Item "$QuickFunctionsRoot\$Function"
            }
        }

        $UtilityBeltAliases = Get-ChildItem ".\UtilityBelt\Aliases"
        foreach($Alias in $UtilityBeltAliases) {
            if (Test-Path "$QuickAliasesRoot\$Alias") {
                Remove-Item "$QuickAliasesRoot\$Alias"
            }
        }
        #todo: Create Remove-Item if exists. Perhaps Remove-Folder and File if exists to express intent
        if (Test-Path $QuickPowershellModulePath) {
            Remove-Item $QuickPowershellModulePath
        }
    } else {
        Remove-Item (Split-Path $QuickPowershellModulePath)
    }   
}
if (Test-Path $QuickPowershellUserProfileRoot) {
    $userProfiles = Get-ChildItem $QuickPowershellUserProfileRoot -Filter '*profile.ps1'
    foreach($userProfile in $userProfiles) {
        (Get-Content $QuickPowershellUserProfileRoot\$userProfile -Raw) -replace 'Import-Module Quick-Package', '' | Out-File $QuickPowershellUserProfileRoot\$userProfile
    }
}