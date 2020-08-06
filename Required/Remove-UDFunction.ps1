function Remove-UDFunction {
    param(
        [String]$functionName,
        [Switch]$force
        )

    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1

    $functionName = Test-UDFunctionVariable $PSBoundParameters 'functionName' 'Please enter the function to remove'

    if (!(Test-Path "$functionsRoot\$functionName.ps1")) {
        if (Test-Path "$helpersRoot\$functionName.ps1") {
            Write-Output "UDFunction-Builder Helpers cannot be removed. To remove function, uninstall UDFunction-Builder."
        }
        Write-Output "Function '$functionName' not found."
        return;
    }

    Remove-Item -Path "$functionsRoot\$functionName.ps1"
}