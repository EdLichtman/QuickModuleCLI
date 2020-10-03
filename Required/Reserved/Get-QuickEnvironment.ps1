$QuickPowershellUserProfileRoot = Split-Path $profile
$QuickFunctionsRoot = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Functions"
$QuickAliasesRoot = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Aliases"
$QuickConfigurationsFile = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Configuration\Configuration.ps1"
$QuickHelpersRoot = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Required"
$QuickReservedHelpersRoot = "$QuickHelpersRoot\Reserved"
$QuickUtilityBeltFunctionsRoot = "$QuickReservedHelpersRoot\UtilityBelt\Functions"
$QuickUtilityBeltAliasesRoot = "$QuickReservedHelpersRoot\UtilityBelt\Aliases"
$QuickPowershellProfilePath = $profile
$QuickPowershellModulePath = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Quick-Package.psm1"
$QuickUtilityBeltCommandIdentifier = "##PREINSTALLED##"
$QuickImportedFunctionIdentifier = "##IMPORTED##"

function Exit-AfterImport {
    #Do Nothing -- Allows us to Mock the function to test that the import headers returned successfully
    return $false;
}

function Test-ImportCompleted {
    #Do Nothing -- Allows us to test whether the function has been called
}