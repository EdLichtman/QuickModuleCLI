function Add-QuickFunction {
    param(
        [string]$functionName
    )

    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1
    . $PSScriptRoot\Add-QuickOneLineFunction.ps1
   
    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    
    Add-QuickOneLineFunction -functionName $functionName -functionText ''
    powershell_ise.exe "$QuickFunctionsRoot\$FunctionName.ps1"
}