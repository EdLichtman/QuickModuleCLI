function Edit-UDCommand {
    param(
        [String]$commandName
    )

    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1

    $commandName = Test-UDFunctionVariable $PSBoundParameters 'commandName' 'Please enter the function/alias to edit'
    if(Test-Path "$functionsRoot\$commandName.ps1") {
        . powershell_ise.exe "$functionsRoot\$commandName.ps1"    
    }
    elseif(Test-Path "$aliasesRoot\$commandName.ps1") {
        . powershell_ise.exe "$aliasesRoot\$commandName.ps1"
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}