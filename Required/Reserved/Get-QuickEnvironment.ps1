$QuickPowershellUserProfileRoot = Split-Path $profile
$QuickFunctionsRoot = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Functions"
$QuickAliasesRoot = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Aliases"
$QuickHelpersRoot = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Required"
$QuickReservedHelpersRoot = "$QuickHelpersRoot\Reserved"
$QuickUtilityBeltFunctionsRoot = "$QuickReservedHelpersRoot\UtilityBelt\Functions"
$QuickUtilityBeltAliasesRoot = "$QuickReservedHelpersRoot\UtilityBelt\Aliases"
$QuickPowershellProfilePath = $profile
$QuickPowershellModulePath = "$QuickPowershellUserProfileRoot\Modules\Quick-Package\Quick-Package.psm1"
$QuickUtilityBeltCommandIdentifier = "##PREINSTALLED##"
$QuickImportedFunctionIdentifier = "##IMPORTED##"

