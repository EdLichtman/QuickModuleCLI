$QuickPackageModuleFolder =  Split-Path (Get-Module -Name QuickModuleCLI).Path
$QuickPackageModuleName = "QuickModuleCLI"
$QuickPackageModuleContainerPath = "$QuickPackageModuleFolder\Modules"
$QuickHelpersRoot = "$QuickPackageModuleFolder\Root"
$QuickReservedHelpersRoot = "$QuickHelpersRoot\Reserved"
$QuickUtilityBeltFunctionsRoot = "$QuickReservedHelpersRoot\UtilityBelt\Functions"
$QuickUtilityBeltAliasesRoot = "$QuickReservedHelpersRoot\UtilityBelt\Aliases"
$QuickPowershellProfilePath = $profile
$QuickPowershellModulePath = "$QuickPackageModuleFolder\$QuickPackageModuleName.psm1"
$QuickUtilityBeltCommandIdentifier = "##PREINSTALLED##"
$QuickImportedFunctionIdentifier = "##IMPORTED##"

function Exit-AfterImport {
    #Do Nothing -- Allows us to Mock the function to test that the import headers returned successfully
    return $false;
}

function Test-ImportCompleted {
    #Do Nothing -- Allows us to test whether the function has been called
}