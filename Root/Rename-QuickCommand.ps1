function Rename-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $commandName,
        [Parameter(Mandatory=$true)][string] $replacement
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

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        $NewFunctionBlock = $FunctionBlock -Replace "$commandName", "$replacement" 

        Remove-Item $Function
        New-FileWithContent -filePath "$NestedModulesFolder\$NestedModule\Functions\$replacement.ps1" -fileText $NewFunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        $NewAliasBlock = $aliasBlock -Replace "Set-Alias $commandName", "Set-Alias $replacement" 

        Remove-Item $Alias
        New-FileWithContent -filePath "$NestedModulesFolder\$NestedModule\Aliases\$replacement.ps1" -fileText $NewAliasBlock
    } 

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force

}