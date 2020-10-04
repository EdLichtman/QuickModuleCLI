function global:Add-QuickAlias {
    param(
        [string]$AliasName,
        [string]$AliasText,
        [string]$QuickModule,
        [Switch]$Raw
    )
    
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1"
    . "$QuickReservedHelpersRoot\Test-CommandExists.ps1"
    . "$QuickReservedHelpersRoot\New-FileWithContent.ps1"

    $AliasName = Test-QuickFunctionVariable $PSBoundParameters 'AliasName' 'Please enter the Alias'
    $AliasText = Test-QuickFunctionVariable $PSBoundParameters 'AliasText' 'Please enter the Function'
    $QuickModule = Test-QuickFunctionVariable $PSBoundParameters 'QuickModule' 'Please enter the name of the Module'
    
    if (Test-CommandExists $aliasName) {
        Write-Output "That alias already exists as a command. $QuickPackageModuleName does not support Clobber."
        return
    }
    if (!(Test-CommandExists $aliasText)) {
        Write-Output "That Function does not exist."
        return
    }

    $newCode = $AliasText
    if (!$Raw){
        $newCode = 
@"
Set-Alias $AliasName $AliasText -Scope Global
"@
    }

    New-FileWithContent -filePath "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1" -fileText $newCode
    Invoke-Expression $newCode

    #Export Member to Module
    # $psd1Location = "$(Split-Path (Get-Module $QuickPackageModuleName).Path)\$QuickPackageModuleName.psd1"
    # $psd1Content = (Get-Content $psd1Location | Out-String)
    # $psd1 = (Invoke-Expression $psd1Content)
    # $NewAliasesToExport = New-Object System.Collections.ArrayList($null)
    # $NewAliasesToExport.AddRange($psd1.AliasesToExport)
    # $NewAliasesToExport.Add($AliasName) | Out-Null
    # $psd1.AliasesToExport = $NewAliasesToExport;
    # Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
}