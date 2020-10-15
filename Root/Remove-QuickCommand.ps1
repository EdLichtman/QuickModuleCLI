function Remove-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$NestedModule,
        [Parameter(Mandatory=$true)][string]$CommandName
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"

    Assert-CanFindQuickCommand -NestedModule $NestedModule -CommandName $CommandName
    
    $Function = Get-QuickFunctionLocation -NestedModule $NestedModule -CommandName $CommandName
    $Alias = Get-QuickAliasLocation -NestedModule $NestedModule -CommandName $CommandName
    
    if(Test-Path $Function) {
        Remove-Item -Path $Function    
    }
    elseif(Test-Path $Alias) {
        Remove-Item -Path $Alias
    } 

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force
}