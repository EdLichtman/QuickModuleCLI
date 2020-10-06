function Remove-QuickModule {
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule
    )
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI'"

    $ModuleDirectory = "$NestedModulesFolder\$NestedModule"
    
    if (!(Test-Path "$ModuleDirectory")) {
        Write-Output "No Module found at: '$ModuleDirectory'"
    } else {
        $Continue = $Host.UI.PromptForChoice("Module found at: '$ModuleDirectory'", "Are you sure you would like to delete?", @('&Yes','&No'), 1);
        if ($Continue -eq 0) {
            Remove-Item $ModuleDirectory -Recurse
            Update-QuickModuleCLI
        }

    }
}