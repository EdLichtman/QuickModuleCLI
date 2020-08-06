function Get-UDModules {
    param(
        [Switch] $IncludeBuiltIn
    )
    
    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    
    if ($IncludeBuiltIn) {
        $helpers = Get-ChildItem $helpersRoot -Filter "*.ps1"
        foreach($helper in $helpers) {
            Write-Output "`r$($helper.Name -replace '.ps1', '')"
        }
    
    }

    $functions = Get-ChildItem $functionsRoot -Filter "*.ps1"
    foreach($function in $functions) {
        Write-Output "`r$($function.Name -replace '.ps1', '')"
    }

    Write-Output "`r";
}