function New-QuickModule {
    param(
        [required][string] $QuickModule
    )
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$QuickReservedHelpersRoot\New-ItemIfNotExists.ps1'"
    
    New-ItemIfNotExists "$QuickPackageModuleContainerPath\$QuickModule"

    # #Export Member to Module
    # $psd1Location = "$(Split-Path (Get-Module $QuickPackageModuleName).Path)\$QuickPackageModuleName.psd1"
    # $psd1Content = (Get-Content $psd1Location | Out-String)
    # $psd1 = (Invoke-Expression $psd1Content)
    # $NewFunctionsToExport = New-Object System.Collections.ArrayList($null)
    # $NewFunctionsToExport.AddRange($psd1.FunctionsToExport)
    # $NewFunctionsToExport.Add($FunctionName) | Out-Null
    # $psd1.FunctionsToExport = $NewFunctionsToExport;
    # Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
}