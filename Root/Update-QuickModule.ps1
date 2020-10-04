function Update-QuickModule {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $QuickModule
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    
    #Remove Exported Member from Module
    $QuickModuleLocation = "$QuickPackageModuleContainerPath\$QuickModule"
    if (!(Test-Path $QuickModuleLocation)) {
        Write-Output "No Quick Module found by the name '$QuickModule'"
        return;
    }
    $psd1Location = "$QuickModuleLocation\$QuickModule.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)
    
    $FunctionsToExport = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ChildItem "$QuickModuleLocation\Functions";
    if ($Functions) {
        $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
    }
    $psd1.FunctionsToExport = $FunctionsToExport

    $AliasesToExport = New-Object System.Collections.ArrayList($null)
    $Aliases = Get-ChildItem "$QuickModuleLocation\Aliases";
    if ($Aliases) {
        $Aliases | ForEach-Object {$AliasesToExport.Add("$($_.BaseName)")} | Out-Null
    }
    $psd1.AliasesToExport = $AliasesToExport

    Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
}