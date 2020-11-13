function Copy-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectExists()]
        [String]$SourceModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandExists()]
        [String]$SourceCommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectExists()]
        [String]$DestinationModuleProject,

        [Parameter(Mandatory=$true)][String]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandDoesNotExist()]
        $DestinationCommandName
    )
    Assert-CommandExistsInModule -ModuleProject $SourceModuleProject -CommandName $SourceCommandName

    $CommandType, $CommandBlock = Get-ModuleProjectCommandDefinition -ModuleProject $SourceModuleProject -CommandName $SourceCommandName

    if ($CommandType -EQ 'Function') {
        Assert-CommandStartsWithApprovedVerb -Command $DestinationCommandName
        New-ModuleProjectFunction -ModuleProject $DestinationModuleProject -CommandName $DestinationCommandName -Text $CommandBlock
        Edit-ModuleCommand -ModuleProject $DestinationModuleProject -CommandName $DestinationCommandName
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $DestinationModuleProject -Alias $DestinationCommandName -CommandName $CommandBlock
    }

    # Update-ModuleProject -NestedModule $DestinationNestedModule

    # Edit-ModuleCommand -NestedModule $DestinationNestedModule -commandName $DestinationCommandName
}
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceCommandName -ScriptBlock (Get-Command Get-CommandFromModuleArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName DestinationModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock