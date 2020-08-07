function Add-QuickAlias {
    param(
        [string]$AliasName,
        [string]$AliasText
    )
    
    . $PSScriptRoot\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Test-QuickFunctionVariable.ps1
    . $PSScriptRoot\Test-CommandExists.ps1
    . $PSScriptRoot\New-FileWithContent.ps1

    $AliasName = Test-QuickFunctionVariable $PSBoundParameters 'AliasName' 'Please enter the Alias'
    $AliasText = Test-QuickFunctionVariable $PSBoundParameters 'AliasText' 'Please enter the Function'
    
    if (Test-CommandExists $aliasName) {
        Write-Output "That alias already exists as a command. Quick-Package does not support Clobber."
        return
    }
    if (!(Test-CommandExists $aliasText)) {
        Write-Output "That Function does not exist."
        return
    }

    $newCode = "Set-Alias $AliasName $AliasText"
    New-FileWithContent -filePath "$QuickAliasesRoot\$AliasName.ps1" -fileText $newCode
}