function Get-QuickCommands {
    param(
        [Switch] $IncludeBuiltIn,
        [Switch] $OnlyIncludeBuiltIn
    )
    
    #todo Add the Alias Target to the Aliases Printout. Format the Functions and Aliases being printed out
    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    
    if ($IncludeBuiltIn -or $OnlyIncludeBuiltIn) {
        $helpers = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
        foreach($helper in $helpers) {
            Write-Output "`r$($helper.Name -replace '.ps1', '')"
        }
    
    }

    if (!$OnlyIncludeBuiltIn) {
        $functions = Get-ChildItem $QuickFunctionsRoot -Filter "*.ps1"
        foreach($function in $functions) {
            Write-Output "`r$($function.Name -replace '.ps1', '')"
        }
    
        $aliases = Get-ChildItem $QuickAliasesRoot -Filter "*.ps1"
        foreach($alias in $aliases) {
            Write-Output "`r$($alias.Name -replace '.ps1', '')"
        }
    }

    Write-Output "`r";
}