function Rename-QuickFunction {
    param(
        [String] $functionName,
        [String] $replacement
    )

    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1
    . $PSScriptRoot\New-FileWithContent.ps1

    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the function name to be renamed'
    $replacement = Test-QuickFunctionVariable $PSBoundParameters 'replacement' 'Please enter the replacement'
    
    $filePath = "$QuickFunctionsRoot\$functionName.ps1"
    if (!(Test-Path $filePath)) {
        Write-Output "Function '$functionName' not found."
        return;
    }

    $FunctionBlock = Get-Content $filePath -Raw
    $NewFunctionBlock = $FunctionBlock -Replace "$FunctionName", "$replacement"

    Remove-QuickFunction -functionName $FunctionName
    New-FileWithContent -filePath "$QuickFunctionsRoot\$replacement.ps1" -fileText $NewFunctionBlock
}