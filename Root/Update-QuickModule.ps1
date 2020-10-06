function Update-QuickModule {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $NestedModule
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    
    #Remove Exported Member from Module
    $NestedModuleLocation = "$NestedModulesFolder\$NestedModule"
    if (!(Test-Path $NestedModuleLocation)) {
        Write-Output "No Quick Module found by the name '$NestedModule'"
        return;
    }
    $psd1Location = "$NestedModuleLocation\$NestedModule.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)
    
    $FunctionsToExport = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ChildItem "$NestedModuleLocation\Functions";
    if ($Functions) {
        $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
    }

    $AliasesToExport = New-Object System.Collections.ArrayList($null)
    $Aliases = Get-ChildItem "$NestedModuleLocation\Aliases";
    if ($Aliases) {
        $Aliases | ForEach-Object {$AliasesToExport.Add("$($_.BaseName)")} | Out-Null
    }

    New-ModuleManifest -Path $psd1Location `
    -FunctionsToExport $FunctionsToExport `
    -AliasesToExport $AliasesToExport `
    -NestedModules $psd1.NestedModules `
    -Author $psd1.Author `
    -Description $psd1.Description `
    -RootModule $psd1.RootModule `
    -ModuleVersion $psd1.ModuleVersion `
    -PowerShellVersion $psd1.PowerShellVersion `
    -CompatiblePSEditions $psd1.CompatiblePSEditions `
    -CmdletsToExport $psd1.CmdletsToExport `
    -Guid $psd1.Guid `
    -CompanyName $psd1.CompanyName `
    -Copyright $psd1.Copyright `
    -ProcessorArchitecture $psd1.ProcessorArchitecture `
    -ClrVersion $psd1.ClrVersion `
    -DotNetFrameworkVersion $psd1.DotNetFrameworkVersion `
    -PowerShellHostName $psd1.PowerShellHostName `
    -PowerShellHostVersion $psd1.PowerShellHostVersion `
    -RequiredModules $psd1.RequiredModules `
    -TypesToProcess $psd1.TypesToProcess `
    -FormatsToProcess $psd1.FormatsToProcess `
    -ScriptsToProcess $psd1.ScriptsToProcess `
    -RequiredAssemblies $psd1.RequiredAssemblies `
    -FileList $psd1.FileList `
    -ModuleList $psd1.ModuleList `
    -VariablesToExport $psd1.VariablesToExport `
    -DscResourcesToExport $psd1.DscResourcesToExport `
    -PrivateData $psd1.PrivateData `
    -Tags $psd1.Tags `
    -ProjectUri $psd1.ProjectUri `
    -LicenseUri $psd1.LicenseUri `
    -IconUri $psd1.IconUri `
    -ReleaseNotes $psd1.ReleaseNotes `
    -HelpInfoUri $psd1.HelpInfoUri 
}