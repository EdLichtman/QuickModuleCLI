function Move-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectExists()]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandExists()]
        [string] $CommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectExists()]
        [string] $DestinationModuleProject
    )
    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName
    
    $CommandType, $CommandBlock = Get-ModuleProjectCommandDefinition -ModuleProject $SourceModuleProject -CommandName $SourceCommandName

    Remove-ModuleCommand -ModuleProject $ModuleProject -CommandName $CommandName
    if ($CommandType -EQ 'Function') {
        New-ModuleProjectFunction -ModuleProject $DestinationModuleProject -CommandName $CommandName -Text $CommandBlock
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $DestinationModuleProject -Alias $CommandName -CommandName $CommandBlock
    }

    #Update-ModuleProject -ModuleProject $ModuleProject
    #Update-ModuleProject -ModuleProject $DestinationModuleProject
    #Import-Module $BaseModuleName -Force
}

Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName DestinationModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock