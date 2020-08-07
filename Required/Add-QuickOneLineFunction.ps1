function Add-QuickOneLineFunction {
    param(
        [string]$functionName,
        [string]$functionText
    )
    
    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1
    . $PSScriptRoot\New-FileWithContent.ps1

    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    $functionText = Test-QuickFunctionVariable $PSBoundParameters 'functionText' 'Please enter the One-Line Function'
    
    $newCode = 
@"
function $FunctionName {
    $FunctionText
}
"@
    New-FileWithContent -filePath "$QuickFunctionsRoot\$FunctionName.ps1" -fileText $newCode
}