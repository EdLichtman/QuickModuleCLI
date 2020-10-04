function global:Remove-QuickUtilityBelt {
    
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"

    $functions = Get-ChildItem $QuickFunctionsRoot
    foreach($function in $functions) {
        if (Get-Content $QuickFunctionsRoot\$function | Select-String $QuickUtilityBeltCommandIdentifier) {
            Remove-Item "$QuickFunctionsRoot\$Function"
        }
    }
    
    $aliases = Get-ChildItem $QuickAliasesRoot
    foreach($alias in $aliases) {
        if (Get-Content $QuickAliasesRoot\$alias | Select-String $QuickUtilityBeltCommandIdentifier) {
            Remove-Item "$QuickAliasesRoot\$alias"
        }
    }
}