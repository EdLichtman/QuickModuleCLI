function Remove-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string]$ModuleProject,
        
        [Parameter(Mandatory=$true)][string]$CommandName
    )
    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName
    
    $Function = Get-ModuleProjectFunctionPath -ModuleProject $ModuleProject -CommandName $CommandName
    $Alias = Get-ModuleProjectAliasPath -ModuleProject $ModuleProject -CommandName $CommandName
    
    if(Test-Path $Function) {
        Remove-Item -Path $Function    
    }
    elseif(Test-Path $Alias) {
        Remove-Item -Path $Alias
    } 

    Update-ModuleProject -ModuleProject $ModuleProject
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}