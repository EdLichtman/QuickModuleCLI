function Copy-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][String]$SourceNestedModule,
        [Parameter(Mandatory=$true)][String]$SourceCommandName,
        [Parameter(Mandatory=$true)][String]$DestinationNestedModule,
        [Parameter(Mandatory=$true)][String]$DestinationCommandName
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    Invoke-Expression ". '$FunctionsFolder\Edit-QuickCommand.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\New-FileWithContent.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Test-QuickCommandExists.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI.ps1'"

    Test-QuickCommandExists $DestinationCommandName

    $Function = "$NestedModulesFolder\$SourceNestedModule\Functions\$SourceCommandName.ps1"
    $Alias = "$NestedModulesFolder\$SourceNestedModule\Aliases\$SourceCommandName.ps1"

    if (!(Test-Path $Function) -and !(Test-Path $Alias)) {
        Write-Output "Command '$SourceCommandName' not found."
        return;
    }

    if (!(Test-Path $NestedModulesFolder\$DestinationNestedModule)) {
        $Continue = $Host.UI.PromptForChoice("No Module by the name '$DestinationNestedModule' exists.", "Would you like to create a new one?", @('&Yes','&No'), 0)
        if ($Continue -eq 0) {
            New-QuickModule -NestedModule $DestinationNestedModule;
        } else {
            return;
        }
    }

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