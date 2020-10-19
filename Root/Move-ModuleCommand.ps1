function Move-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $CommandName,
        [Parameter(Mandatory=$true)][string] $DestinationNestedModule
    )
    
    $Function = Get-ModuleFunctionLocation -NestedModule $NestedModule -CommandName $CommandName
    $Alias = Get-ModuleAliasLocation -NestedModule $NestedModule -CommandName $CommandName
    $DestinationFunctionPath = Get-ModuleFunctionLocation -NestedModule $DestinationNestedModule -CommandName $CommandName
    $DestinationAliasPath = Get-ModuleAliasLocation -NestedModule $DestinationNestedModule -CommandName $CommandName

    Assert-CanFindModuleCommand -NestedModule $NestedModule -CommandName $CommandName

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        
        Remove-Item $Function
        New-FileWithContent -filePath $DestinationFunctionPath -fileText $FunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        
        Remove-Item $Alias
        New-FileWithContent -filePath $DestinationAliasPath -fileText $aliasBlock
    } 

    Update-ModuleProject -NestedModule $NestedModule
    Update-ModuleProject -NestedModule $DestinationNestedModule
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}