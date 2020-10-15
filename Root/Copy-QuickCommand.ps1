function Copy-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][String]$SourceNestedModule,
        [Parameter(Mandatory=$true)][String]$SourceCommandName,
        [Parameter(Mandatory=$true)][String]$DestinationNestedModule,
        [Parameter(Mandatory=$true)][String]$DestinationCommandName
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Edit-QuickCommand.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"

    Assert-CanCreateQuickCommand $DestinationCommandName

    $Function = "$NestedModulesFolder\$SourceNestedModule\Functions\$SourceCommandName.ps1"
    $Alias = "$NestedModulesFolder\$SourceNestedModule\Aliases\$SourceCommandName.ps1"

    Assert-CanFindQuickCommand -NestedModule $SourceNestedModule -CommandName $SourceCommandName
    Assert-TryCreateModule -NestedModule $DestinationNestedModule

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        $NewFunctionBlock = $FunctionBlock -Replace "$SourceCommandName", "$DestinationCommandName" 
        New-FileWithContent -filePath "$NestedModulesFolder\$DestinationNestedModule\Functions\$DestinationCommandName.ps1" -fileText $NewFunctionBlock
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        $NewAliasBlock = $aliasBlock -Replace "Set-Alias $SourceCommandName", "Set-Alias $DestinationCommandName"
        New-FileWithContent -filePath "$NestedModulesFolder\$DestinationNestedModule\Aliases\$DestinationCommandName.ps1" -fileText $NewAliasBlock
    } 

    Update-QuickModule -NestedModule $DestinationNestedModule
    Update-QuickModuleCLI

    Edit-QuickCommand -NestedModule $DestinationNestedModule -commandName $DestinationCommandName
}