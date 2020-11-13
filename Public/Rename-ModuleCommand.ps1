function Rename-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter([ModuleProjectArgument])]
        [string] $NestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandExists()]
        [ArgumentCompleter([CommandFromModuleArgument])]
        [string] $CommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandDoesNotExist()]
        [ValidateParameterStartsWithApprovedVerb()]
        [ArgumentCompleter([ApprovedVerbsArgument])]
        [string] $Replacement
    )

    $Function = Get-ModuleProjectFunctionPath -ModuleProject $NestedModule -CommandName $CommandName
    $Alias = Get-ModuleProjectAliasPath -ModuleProject $NestedModule -CommandName $CommandName
    $ReplacementFunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $NestedModule -CommandName $Replacement
    $ReplacementAliasPath = Get-ModuleProjectAliasPath -ModuleProject $NestedModule -CommandName $Replacement

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

    #Update-ModuleProject -NestedModule $NestedModule
    #Import-Module $BaseModuleName -Force

}