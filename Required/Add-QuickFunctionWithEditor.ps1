function global:Add-QuickFunctionWithEditor {
    param(
        [string]$functionName
    )

    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1"
    . "$PSScriptRoot\Add-QuickFunction.ps1"
   
    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    
    Add-QuickFunction -functionName $functionName -functionText ''
    powershell_ise.exe "$QuickFunctionsRoot\$FunctionName.ps1"
}