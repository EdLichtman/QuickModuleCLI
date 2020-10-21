function Copy-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [String]$SourceNestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Assert-ModuleCommandExists)})]
        [String]$SourceCommandName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Assert-ModuleProjectDoesNotExist)})]
        [String]$DestinationNestedModule,

        [Parameter(Mandatory=$true)][String]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Assert-ModuleCommandDoesNotExist)})]
        $DestinationCommandName
    )

    Assert-CanCreateModuleCommand $DestinationCommandName -NestedModule $DestinationNestedModule

    $Function = "$NestedModulesFolder\$SourceNestedModule\Functions\$SourceCommandName.ps1"
    $Alias = "$NestedModulesFolder\$SourceNestedModule\Aliases\$SourceCommandName.ps1"

    Assert-CanFindModuleCommand -NestedModule $SourceNestedModule -CommandName $SourceCommandName

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