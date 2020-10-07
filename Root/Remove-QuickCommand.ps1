function Remove-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string]$NestedModule,
        [Parameter(Mandatory=$true)][string]$commandName
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI'"

    $Function = "$NestedModulesFolder\$NestedModule\Functions\$commandName.ps1"
    $Alias ="$NestedModulesFolder\$NestedModule\Aliases\$commandName.ps1"

    if (!(Test-Path $Function) -and !(Test-Path $Alias)) {
        Write-Output "Command '$commandName' not found."
        return;
    }
    if(Test-Path $Function) {
        Remove-Item -Path $Function    

        if (Test-Path function:\$commandName) {
            Remove-Item function:\$commandName
        }
    }
    elseif(Test-Path $Alias) {
        Remove-Item -Path $Alias
        
        if (Test-Path alias:\$commandName) {
            Remove-Item alias:\$commandName
        }
    } 

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force
}