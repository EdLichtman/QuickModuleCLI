function Copy-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [String]$SourceNestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandExists()]
        [String]$SourceCommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectDoesNotExist()]
        [String]$DestinationNestedModule,

        [Parameter(Mandatory=$true)][String]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandDoesNotExist()]
        $DestinationCommandName
    )
    Assert-CommandExistsInModule -ModuleProject $SourceNestedModule -CommandName $SourceCommandName

    $Function = "$NestedModulesFolder\$SourceNestedModule\Functions\$SourceCommandName.ps1"
    $Alias = "$NestedModulesFolder\$SourceNestedModule\Aliases\$SourceCommandName.ps1"

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        $NewFunctionBlock = $FunctionBlock -Replace "$SourceCommandName", "$DestinationCommandName" 
        New-FileWithContent -filePath "$NestedModulesFolder\$DestinationNestedModule\Functions\$DestinationCommandName.ps1" -fileText $NewFunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        $NewAliasBlock = $aliasBlock -Replace "Set-Alias $SourceCommandName", "Set-Alias $DestinationCommandName"
        New-FileWithContent -filePath "$NestedModulesFolder\$DestinationNestedModule\Aliases\$DestinationCommandName.ps1" -fileText $NewAliasBlock
    } 

    Update-ModuleProject -NestedModule $DestinationNestedModule
    Update-ModuleProjectCLI

    Edit-ModuleCommand -NestedModule $DestinationNestedModule -commandName $DestinationCommandName
}