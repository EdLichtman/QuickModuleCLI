function Rename-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $CommandName,
        [Parameter(Mandatory=$true)][string] $Replacement
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    
    Assert-CanFindQuickCommand -NestedModule $NestedModule -CommandName $CommandName
    Assert-CanCreateQuickCommand -CommandName $Replacement -NestedModule $NestedModule

    $Function = Get-QuickFunctionLocation -NestedModule $NestedModule -CommandName $CommandName
    $Alias = Get-QuickAliasLocation -NestedModule $NestedModule -CommandName $CommandName
    $ReplacementFunctionPath = Get-QuickFunctionLocation -NestedModule $NestedModule -CommandName $Replacement
    $ReplacementAliasPath = Get-QuickAliasLocation -NestedModule $NestedModule -CommandName $Replacement

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        $NewFunctionBlock = $FunctionBlock -Replace "$commandName", "$replacement" 

        Remove-Item $Function
        New-FileWithContent -filePath $ReplacementFunctionPath -fileText $NewFunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        $NewAliasBlock = $aliasBlock -Replace "Set-Alias $commandName", "Set-Alias $replacement" 

        Remove-Item $Alias
        New-FileWithContent -filePath $ReplacementAliasPath -fileText $NewAliasBlock
    } 

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force

}