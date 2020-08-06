function Add-UDOneLineFunction {
    param(
        [string]$functionName,
        [string]$functionText
    )
    
    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1
    . $PSScriptRoot\New-FileWithContent.ps1

    $functionName = Test-UDFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    $functionText = Test-UDFunctionVariable $PSBoundParameters 'functionText' 'Please enter the One-Line Function'
    
    $newCode = 
@"
function $FunctionName {
    $FunctionText
}
"@
    New-FileWithContent -filePath "$functionsRoot\$FunctionName.ps1" -fileText $newCode
}