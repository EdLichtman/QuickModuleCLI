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
        [string] $NewCommandName,

        [Parameter()]
        [Switch]
        $Force
    )
    
    ValidateCommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName

    $CommandType = GetModuleProjectTypeForCommand -CommandName $CommandName
    $CommandBlock = GetDefinitionForCommand -CommandName $CommandName
    
    if ($CommandType -EQ 'Function' -and (!$Force)) {
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