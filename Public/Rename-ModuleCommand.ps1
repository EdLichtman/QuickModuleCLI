function Rename-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandExists $_})]
        [string] $CommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandDoesNotExist $_})]
        [string] $NewCommandName
    )
    
    ValidateCommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName

    $CommandType, $CommandBlock = Get-ModuleProjectCommandDefinition -ModuleProject $ModuleProject -CommandName $CommandName
    if ($CommandType -EQ 'Function') {
        ValidateCommandStartsWithApprovedVerb -Command $NewCommandName
    }

    Remove-ModuleProjectCommand -ModuleProject $ModuleProject -CommandName $CommandName

    if ($CommandType -EQ 'Function') {
        New-ModuleProjectFunction -ModuleProject $ModuleProject -CommandName $NewCommandName -Text $CommandBlock
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $ModuleProject -Alias $NewCommandName -CommandName $CommandBlock
    }

    Update-ModuleProject -ModuleProject $ModuleProject
    Import-Module $BaseModuleName -Force -Global

}

Register-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command CommandFromOptionalModuleArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName NewCommandName -ScriptBlock (Get-Command NewCommandFromModuleArgumentCompleter).ScriptBlock