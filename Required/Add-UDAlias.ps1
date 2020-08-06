function Add-UDAlias {
    param(
        [string]$AliasName,
        [string]$AliasText
    )
    
    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Test-UDFunctionVariable.ps1
    . $PSScriptRoot\Test-CommandExists.ps1
    . $PSScriptRoot\New-FileWithContent.ps1

    $AliasName = Test-UDFunctionVariable $PSBoundParameters 'AliasName' 'Please enter the Alias'
    $AliasText = Test-UDFunctionVariable $PSBoundParameters 'AliasText' 'Please enter the Function'
    
    if (Test-CommandExists $aliasName) {
        Write-Output "That alias already exists as a command. UDFunction-Builder does not support Clobber."
        return
    }
    if (!(Test-CommandExists $aliasText)) {
        Write-Output "That Function does not exist."
        return
    }

    $newCode = "Set-Alias $AliasName $AliasText"
    New-FileWithContent -filePath "$aliasesRoot\$AliasName.ps1" -fileText $newCode
}