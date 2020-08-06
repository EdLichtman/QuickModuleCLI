function Rename-UDFunction {
    param(
        [String] $functionName,
        [String] $replacement
    )

    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1
    . $PSScriptRoot\New-FileWithContent.ps1

    $functionName = Test-UDFunctionVariable $PSBoundParameters 'functionName' 'Please enter the function name to be renamed'
    $replacement = Test-UDFunctionVariable $PSBoundParameters 'replacement' 'Please enter the replacement'
    
    $filePath = "$functionsRoot\$functionName.ps1"
    if (!(Test-Path $filePath)) {
        Write-Output "Function '$functionName' not found."
        return;
    }

    $FunctionBlock = Get-Content $filePath -Raw
    $NewFunctionBlock = $FunctionBlock -Replace "$FunctionName", "$replacement"

    Remove-UDFunction -functionName $FunctionName
    New-FileWithContent -filePath "$functionsRoot\$replacement.ps1" -fileText $NewFunctionBlock
}