function Update-QuickModule {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $QuickModule
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    
         #Remove Exported Member from Module
        $psd1Location = "$(Split-Path (Get-Module $QuickPackageModuleName).Path)\$QuickPackageModuleName.psd1"
        $psd1Content = (Get-Content $psd1Location | Out-String)
        $psd1 = (Invoke-Expression $psd1Content)
        $NewAliasesToExport = New-Object System.Collections.ArrayList($null)
        $NewAliasesToExport.AddRange($psd1.AliasesToExport)
        $NewAliasesToExport.Remove($commandName) | Out-Null
        $psd1.AliasesToExport = $NewAliasesToExport;
        Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
}