function Copy-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [String]$SourceModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandExists $_})]
        [String]$CommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [String]$DestinationModuleProject,

        [Parameter(Mandatory=$true)][String]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandDoesNotExist $_})]
        $NewCommandName
    )
    if ($SourceModuleProject) {
        ValidateCommandExistsInModule -ModuleProject $SourceModuleProject -CommandName $CommandName
    }

    $CommandType, $CommandBlock = Get-ModuleProjectCommandDefinition -ModuleProject $SourceModuleProject -CommandName $CommandName

    if ($CommandType -EQ 'Function') {
        ValidateCommandStartsWithApprovedVerb -Command $NewCommandName
        New-ModuleProjectFunction -ModuleProject $DestinationModuleProject -CommandName $NewCommandName -Text $CommandBlock
        Edit-ModuleCommand -ModuleProject $DestinationModuleProject -CommandName $NewCommandName
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $DestinationModuleProject -Alias $NewCommandName -CommandName $CommandBlock
    }

    # Update-ModuleProject -NestedModule $DestinationNestedModule

    # Edit-ModuleCommand -NestedModule $DestinationNestedModule -commandName $NewCommandName
}
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command CommandFromOptionalModuleArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName DestinationModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName NewCommandName -ScriptBlock (Get-Command NewCommandFromModuleArgumentCompleter).ScriptBlock