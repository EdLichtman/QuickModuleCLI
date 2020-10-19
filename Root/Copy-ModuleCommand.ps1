function Copy-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][String]$SourceNestedModule,
        [Parameter(Mandatory=$true)][String]$SourceCommandName,
        [Parameter(Mandatory=$true)][String]$DestinationNestedModule,
        [Parameter(Mandatory=$true)][String]$DestinationCommandName
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