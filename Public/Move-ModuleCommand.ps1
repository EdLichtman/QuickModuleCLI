function Move-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
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
    ValidateCommandExistsInModule -ModuleProject $SourceModuleProject -CommandName $CommandName
    ValidateModuleCommandMoveDestinationIsValid -SourceModuleProject $SourceModuleProject -DestinationModuleProject $DestinationModuleProject

    $CommandType, $CommandBlock = Get-ModuleProjectCommandDefinition -ModuleProject $SourceModuleProject -CommandName $CommandName
    Remove-ModuleProjectCommand -ModuleProject $SourceModuleProject -CommandName $CommandName

    if ($CommandType -EQ 'Function') {
        New-ModuleProjectFunction -ModuleProject $DestinationModuleProject -CommandName $CommandName -Text $CommandBlock
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $DestinationModuleProject -Alias $CommandName -CommandName $CommandBlock
    }

    Update-ModuleProject -ModuleProject $SourceModuleProject
    Update-ModuleProject -ModuleProject $DestinationModuleProject
    Import-Module $BaseModuleName -Force -Global
}

Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName SourceModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command CommandFromOptionalModuleArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName DestinationModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock