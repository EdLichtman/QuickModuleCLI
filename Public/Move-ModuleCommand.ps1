function Move-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $SourceModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandExists $_})]
        [string] $CommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $DestinationModuleProject
    )
    Assert-CommandExistsInModule -ModuleProject $SourceModuleProject -CommandName $CommandName
    
    $CommandType, $CommandBlock = Get-ModuleProjectCommandDefinition -ModuleProject $SourceModuleProject -CommandName $CommandName

    Remove-ModuleCommand -ModuleProject $SourceModuleProject -CommandName $CommandName
    if ($CommandType -EQ 'Function') {
        New-ModuleProjectFunction -ModuleProject $DestinationModuleProject -CommandName $CommandName -Text $CommandBlock
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $DestinationModuleProject -Alias $CommandName -CommandName $CommandBlock
    }

    #Update-ModuleProject -ModuleProject $ModuleProject
    #Update-ModuleProject -ModuleProject $DestinationModuleProject
    #Import-Module $BaseModuleName -Force
}

Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName SourceModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command Get-CommandFromModuleArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName DestinationModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock