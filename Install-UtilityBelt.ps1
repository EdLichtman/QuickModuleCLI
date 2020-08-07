$localHelpersPath = ".\Required"
. $localHelpersPath\Get-QuickEnvironment.ps1

$QuickForceText = if ($Force) { '-force' } else { '' }

$localUtilityBeltPath = ".\UtilityBelt"
$localUtilityBeltFunctionsPath = "$localUtilityBeltPath\Functions"
$utilityBeltFunctions = @(Get-ChildItem $localUtilityBeltFunctionsPath -Filter '*.ps1')
foreach($function in $utilityBeltFunctions) {
    Invoke-Expression "New-FileWithContent -FilePath $QuickFunctionsRoot\$function -FileText (Get-Content $localUtilityBeltFunctionsPath\$function -Raw) $QuickForceText"
}

$localUtilityBeltAliasesPath = "$localUtilityBeltPath\Aliases"
$utilityBeltAliases = @(Get-ChildItem $localUtilityBeltAliasesPath -Filter '*.ps1')
foreach($alias in $utilityBeltAliases) {
    Invoke-Expression "New-FileWithContent -FilePath $QuickAliasesRoot\$alias -FileText (Get-Content $localUtilityBeltAliasesPath\$alias -Raw) $QuickForceText"
}