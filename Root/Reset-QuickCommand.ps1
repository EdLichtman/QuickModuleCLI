function Reset-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string]$NestedModule,
        [Parameter(Mandatory=$true)][string]$commandName
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1

    $Function = "$NestedModulesFolder\$NestedModule\Functions\$commandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$commandName.ps1"

    if(Test-Path "$Function") {
        . "$Function" 
    }
    elseif(Test-Path "$Alias") {
        . "$Alias"
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}