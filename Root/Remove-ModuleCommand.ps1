function Remove-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$NestedModule,
        [Parameter(Mandatory=$true)][string]$CommandName
    )

    Assert-CanFindModuleCommand -NestedModule $NestedModule -CommandName $CommandName
    
    $Function = Get-ModuleFunctionLocation -NestedModule $NestedModule -CommandName $CommandName
    $Alias = Get-ModuleAliasLocation -NestedModule $NestedModule -CommandName $CommandName
    
    if(Test-Path $Function) {
        Remove-Item -Path $Function    
    }
    elseif(Test-Path $Alias) {
        Remove-Item -Path $Alias
    } 

    Update-ModuleProject -NestedModule $NestedModule
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}