function Remove-UDAlias {
    param(
        [String]$aliasName
    )

    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1

    $aliasName = Test-UDFunctionVariable $PSBoundParameters 'aliasName' 'Please enter the alias to remove'
    if (!(Test-Path "$aliasesRoot\$aliasName.ps1")) {
        Write-Output "Alias '$aliasName' not found."
        return;
    }

    Remove-Item -Path "$aliasesRoot\$aliasName.ps1"

    if (Test-Path alias:\$aliasName) {
        Remove-Item alias:\$aliasName
    }
}