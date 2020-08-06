function Add-UDFunction {
    param(
        [string]$functionName
    )

    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1
    . $PSScriptRoot\Add-UDOneLineFunction.ps1
   
    $functionName = Test-UDFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    
    Add-UDOneLineFunction -functionName $functionName -functionText ''
    powershell_ise.exe "$functionsRoot\$FunctionName.ps1"
}