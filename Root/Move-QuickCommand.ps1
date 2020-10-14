function Move-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $commandName,
        [Parameter(Mandatory=$true)][string] $DestinationNestedModule
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\New-FileWithContent.ps1'"
    
    $Function = "$NestedModulesFolder\$NestedModule\Functions\$commandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$commandName.ps1"

    if (!(Test-Path $Function) -and !(Test-Path $Alias)) {
        Write-Output "Command '$commandName' not found."
        return;
    }

    if (!(Test-Path $NestedModulesFolder\$DestinationNestedModule)) {
        if ((Get-Module -ListAvailable $NestedModule)) {
            throw [System.ArgumentException] "A module is already available by the name '$NestedModule'. This module does not support clobber and Prefixes."
        }
        $Continue = $Host.UI.PromptForChoice("No Module by the name '$DestinationNestedModule' exists.", "Would you like to create a new one?", @('&Yes','&No'), 0)
        if ($Continue -eq 0) {
            New-QuickModule -NestedModule $DestinationNestedModule;
        } else {
            return;
        }
    }

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        
        Remove-Item $Function
        New-FileWithContent -filePath "$NestedModulesFolder\$DestinationNestedModule\Functions\$commandName.ps1" -fileText $FunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        
        Remove-Item $Alias
        New-FileWithContent -filePath "$NestedModulesFolder\$DestinationNestedModule\Aliases\$commandName.ps1" -fileText $aliasBlock
    } 

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModule -NestedModule $DestinationNestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force
}