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
        Write-Output "Deleting module at '$ModuleDirectory'"
    }

    Update-QuickModuleCLI
}