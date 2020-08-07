function Edit-QuickCommand {
    param(
        [String]$commandName
    )

    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1

    $commandName = Test-QuickFunctionVariable $PSBoundParameters 'commandName' 'Please enter the function/alias to edit'
    if(Test-Path "$QuickFunctionsRoot\$commandName.ps1") {
        . powershell_ise.exe "$QuickFunctionsRoot\$commandName.ps1"    
    }
    elseif(Test-Path "$QuickAliasesRoot\$commandName.ps1") {
        . powershell_ise.exe "$QuickAliasesRoot\$commandName.ps1"
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}