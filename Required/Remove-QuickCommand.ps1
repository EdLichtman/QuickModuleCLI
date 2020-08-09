function global:Remove-QuickCommand {
    param(
        [String]$commandName
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1

    $commandName = Test-QuickFunctionVariable $PSBoundParameters 'commandName' 'Please enter the function/alias to remove'
    if(Test-Path "$QuickFunctionsRoot\$commandName.ps1") {
        Remove-Item -Path "$QuickFunctionsRoot\$commandName.ps1"    

        if (Test-Path function:\$commandName) {
            Remove-Item function:\$commandName
        }
    }
    elseif(Test-Path "$QuickAliasesRoot\$commandName.ps1") {
        Remove-Item -Path "$QuickAliasesRoot\$commandName.ps1"
        
        if (Test-Path alias:\$commandName) {
            Remove-Item alias:\$commandName
        }
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}