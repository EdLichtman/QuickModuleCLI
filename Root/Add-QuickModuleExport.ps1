function Add-QuickModuleExport {
    param(
        [required][string] $QuickModule,
        [string]$FunctionToExport,
        [string]$AliasToExport
    )
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