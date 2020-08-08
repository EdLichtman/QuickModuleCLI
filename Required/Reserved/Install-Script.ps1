param(
    [Switch] $Force
)

$localHelpersPath = "$PSScriptRoot\.."
$localReservedHelpersPath = "$localHelpersPath\Reserved"
$localUtilityBeltFunctionsPath = "$localReservedHelpersPath\UtilityBelt\Functions"
$localUtilityBeltAliasesPath = "$localReservedHelpersPath\UtilityBelt\Aliases"

. "$localReservedHelpersPath\Get-QuickEnvironment.ps1"
. "$localReservedHelpersPath\New-FolderIfNotExists.ps1"
. "$localReservedHelpersPath\New-FileWithContent.ps1"

$QuickForceText = if ($Force) { '-force' } else { '' }

New-FolderIfNotExists $QuickPowershellUserProfileRoot
New-FolderIfNotExists $QuickFunctionsRoot
New-FolderIfNotExists $QuickAliasesRoot
New-FolderIfNotExists $QuickHelpersRoot
New-FolderIfNotExists $QuickUtilityBeltFunctionsRoot
New-FolderIfNotExists $QuickUtilityBeltAliasesRoot

$helpers = @(Get-ChildItem $localHelpersPath -Filter '*.ps1')
foreach($helper in $helpers) {
    if (!(Test-Path $QuickHelpersRoot\$helper) -or $Force){
        Invoke-Expression "New-FileWithContent -FilePath $QuickHelpersRoot\$helper -FileText (Get-Content $localHelpersPath\$helper -Raw) $QuickForceText"
    } 
}
$reservedHelpers = @(Get-ChildItem $localReservedHelpersPath -Filter '*.ps1')
foreach ($reservedHelper in $reservedHelpers) {
    if (!(Test-Path $QuickReservedHelpersRoot\$reservedHelper) -or $Force){
        Invoke-Expression "New-FileWithContent -FilePath $QuickReservedHelpersRoot\$reservedHelper -FileText (Get-Content $localReservedHelpersPath\$reservedHelper -Raw) $QuickForceText"
    } 
}
$UtilityBeltFunctions = @(Get-ChildItem $localUtilityBeltFunctionsPath)
foreach($utilityFunction in $UtilityBeltFunctions) {
    if (!(Test-Path $QuickUtilityBeltFunctionsRoot\$utilityFunction) -or $Force){
        Invoke-Expression "New-FileWithContent -FilePath $QuickUtilityBeltFunctionsRoot\$utilityFunction -FileText (Get-Content $localUtilityBeltFunctionsPath\$utilityFunction -Raw) $QuickForceText"
    } 
}
$UtilityBeltAliases = @(Get-ChildItem $localUtilityBeltAliasesPath)
foreach($utilityAlias in $UtilityBeltAliases) {
    if (!(Test-Path $QuickUtilityBeltAliasesRoot\$utilityAlias) -or $Force){
        Invoke-Expression "New-FileWithContent -FilePath $QuickUtilityBeltAliasesRoot\$utilityAlias -FileText (Get-Content $localUtilityBeltAliasesPath\$utilityAlias -Raw) $QuickForceText"
    } 
}

if ($Force -and (Test-Path $QuickPowershellProfilePath)) {
    Remove-Item $QuickPowershellProfilePath
}
if (!(Test-Path $QuickPowershellProfilePath)) {
    New-FileWithContent $QuickPowershellProfilePath ''
}
if (!(Get-Content $QuickPowershellProfilePath | Select-String 'Import-Module Quick-Package')) {
    Add-Content $QuickPowershellProfilePath `
@"
Import-Module Quick-Package
"@
    
}

if ($Force -and (Test-Path $QuickPowershellModulePath)) {
    Remove-Item $QuickPowershellModulePath
}
if (!(Test-Path $QuickPowershellModulePath)) {
    New-FileWithContent $QuickPowershellModulePath  `
@"
$('$helperFunctions') = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
foreach($('$helperFunction') in $('$helperFunctions')) {
    . $QuickHelpersRoot\$('$helperFunction')
}

$('$functions') = Get-ChildItem $QuickFunctionsRoot -Filter "*.ps1"
foreach($('$function') in $('$functions')) {
    . $QuickFunctionsRoot\$('$function')
}
$('$aliases') = Get-ChildItem $QuickAliasesRoot -Filter "*.ps1"
foreach($('$alias') in $('$aliases')) {
    . $QuickAliasesRoot\$('$alias')
}
"@

}
