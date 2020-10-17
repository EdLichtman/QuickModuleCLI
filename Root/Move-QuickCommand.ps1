function Move-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $CommandName,
        [Parameter(Mandatory=$true)][string] $DestinationNestedModule
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    
    $Function = Get-QuickFunctionLocation -NestedModule $NestedModule -CommandName $CommandName
    $Alias = Get-QuickAliasLocation -NestedModule $NestedModule -CommandName $CommandName
    $DestinationFunctionPath = Get-QuickFunctionLocation -NestedModule $DestinationNestedModule -CommandName $CommandName
    $DestinationAliasPath = Get-QuickAliasLocation -NestedModule $DestinationNestedModule -CommandName $CommandName

    Assert-CanFindQuickCommand -NestedModule $NestedModule -CommandName $CommandName

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        
        Remove-Item $Function
        New-FileWithContent -filePath $DestinationFunctionPath -fileText $FunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        
        Remove-Item $Alias
        New-FileWithContent -filePath $DestinationAliasPath -fileText $aliasBlock
    } 

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModule -NestedModule $DestinationNestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force
}