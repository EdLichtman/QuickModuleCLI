function Remove-QuickAlias {
    param(
        [String]$aliasName
    )

    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1

    $aliasName = Test-QuickFunctionVariable $PSBoundParameters 'aliasName' 'Please enter the alias to remove'
    if (!(Test-Path "$QuickAliasesRoot\$aliasName.ps1")) {
        Write-Output "Alias '$aliasName' not found."
        return;
    }

    Remove-Item -Path "$QuickAliasesRoot\$aliasName.ps1"

    if (Test-Path alias:\$aliasName) {
        Remove-Item alias:\$aliasName
    }
}