. "$PSScriptRoot\Root\Reserved\Get-QuickEnvironment.ps1"
. "$QuickReservedHelpersRoot\New-ItemIfNotExists.ps1"

New-ItemIfNotExists $QuickFunctionsRoot -ItemType Directory
New-ItemIfNotExists $QuickAliasesRoot -ItemType Directory
New-ItemIfNotExists $QuickConfigurationsFile -ItemType File

$helperFunctions = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
    $helperName = $helperFunction.BaseName;
    if (!$helperName.EndsWith('.Tests')) {
        . $QuickHelpersRoot\$helperFunction
        Export-ModuleMember -Function $helperName
    }
}

$functions = Get-ChildItem $QuickFunctionsRoot -Filter "*.ps1"
foreach($function in $functions) {
    . $QuickFunctionsRoot\$function
    Export-ModuleMember -Function $function.BaseName;
}

$aliases = Get-ChildItem $QuickAliasesRoot -Filter "*.ps1"
foreach($alias in $aliases) {
    . $QuickAliasesRoot\$alias
    Export-ModuleMember -Alias $alias.BaseName;
}


. $QuickConfigurationsFile