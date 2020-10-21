function Rename-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $CommandName,
        [Parameter(Mandatory=$true)][string] $Replacement
    )
    
    Assert-CanFindModuleCommand -NestedModule $NestedModule -CommandName $CommandName
    Assert-CanCreateModuleCommand -CommandName $Replacement -NestedModule $NestedModule

    $Function = Get-ModuleFunctionLocation -NestedModule $NestedModule -CommandName $CommandName
    $Alias = Get-ModuleAliasLocation -NestedModule $NestedModule -CommandName $CommandName
    $ReplacementFunctionPath = Get-ModuleFunctionLocation -NestedModule $NestedModule -CommandName $Replacement
    $ReplacementAliasPath = Get-ModuleAliasLocation -NestedModule $NestedModule -CommandName $Replacement

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

    Update-ModuleProject -NestedModule $NestedModule
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force

}