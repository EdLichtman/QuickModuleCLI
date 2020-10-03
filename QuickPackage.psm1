. "$PSScriptRoot\Required\Reserved\Get-QuickEnvironment.ps1"

$helperFunctions = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
    if (!$helperFunction.Name.EndsWith('.Tests.ps1')) {
        . $QuickHelpersRoot\$helperFunction
    }
}

$functions = Get-ChildItem $QuickFunctionsRoot -Filter "*.ps1"
foreach($function in $functions) {
    . $QuickFunctionsRoot\$function
}
$aliases = Get-ChildItem $QuickAliasesRoot -Filter "*.ps1"
foreach($alias in $aliases) {
    . $QuickAliasesRoot\$alias
}

if (!(Test-Path $QuickConfigurationsFile)) {
    New-Item -Path $QuickConfigurationsFile -Type 'File'
}
. $QuickConfigurationsFile