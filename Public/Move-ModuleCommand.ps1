function Move-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [string] $CommandName,

        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $DestinationModuleProject
    )
    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName
    
    $Function = Get-ModuleProjectFunctionPath -ModuleProject $ModuleProject -CommandName $CommandName
    $Alias = Get-ModuleProjectAliasPath -ModuleProject $ModuleProject -CommandName $CommandName
    $DestinationFunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $DestinationModuleProject -CommandName $CommandName
    $DestinationAliasPath = Get-ModuleProjectAliasPath -ModuleProject $DestinationModuleProject -CommandName $CommandName


    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        
        Remove-Item $Function
        New-FileWithContent -filePath $DestinationFunctionPath -fileText $FunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        
        Remove-Item $Alias
        New-FileWithContent -filePath $DestinationAliasPath -fileText $aliasBlock
    } 

    Update-ModuleProject -ModuleProject $ModuleProject
    Update-ModuleProject -ModuleProject $DestinationModuleProject
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}