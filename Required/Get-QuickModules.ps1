function Get-QuickModules {
    param(
        [Switch] $IncludeBuiltIn
    )
    
    #todo Add the Alias Target to the Aliases Printout. Format the Functions and Aliases being printed out
    . $PSScriptRoot\Get-QuickEnvironment.ps1
    
    if ($IncludeBuiltIn) {
        $helpers = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
        foreach($helper in $helpers) {
            Write-Output "`r$($helper.Name -replace '.ps1', '')"
        }
    
    }

    $functions = Get-ChildItem $QuickFunctionsRoot -Filter "*.ps1"
    foreach($function in $functions) {
        Write-Output "`r$($function.Name -replace '.ps1', '')"
    }

    $aliases = Get-ChildItem $QuickAliasesRoot -Filter "*.ps1"
    foreach($alias in $aliases) {
        Write-Output "`r$($alias.Name -replace '.ps1', '')"
    }

    Write-Output "`r";
}