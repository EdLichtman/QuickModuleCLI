function Remove-QuickFunction {
    param(
        [String]$functionName,
        [Switch]$force
        )

    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1

    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the function to remove'

    if (!(Test-Path "$QuickFunctionsRoot\$functionName.ps1")) {
        if (Test-Path "$QuickHelpersRoot\$functionName.ps1") {
            Write-Output "Quick-Package Helpers cannot be removed. To remove function, uninstall Quick-Package."
        }
        Write-Output "Function '$functionName' not found."
        return;
    }

    Remove-Item -Path "$QuickFunctionsRoot\$functionName.ps1"
}