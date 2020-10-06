function Update-QuickModuleCLI {
    Invoke-Expression ". '$PSScriptRoot\Get-QuickEnvironment.ps1'"
    $psd1Location = "$BaseFolder\$BaseModuleName.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)

    $FunctionsToExport = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ChildItem "$FunctionsFolder" -File
    if ($Functions) {
        $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
    }

    $AliasesToExport = New-Object System.Collections.ArrayList($null)

    $NestedModules = New-Object System.Collections.ArrayList($null)
    foreach($Module in Get-ChildItem $NestedModulesFolder) {
        $ModuleName = $Module.BaseName;
        $NestedModules.Add("Modules\$ModuleName\$ModuleName") | Out-Null
        $QuickModuleLocation = "$NestedModulesFolder\$ModuleName"
        if (Test-Path "$QuickModuleLocation\Functions") {
            $Functions = Get-ChildItem "$QuickModuleLocation\Functions" -File;
            if ($Functions) {
                $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
            }
        }

        if (Test-Path "$QuickModuleLocation\Aliases") {
            $Aliases = Get-ChildItem "$QuickModuleLocation\Aliases" -File;
            if ($Aliases) {
                $Aliases | ForEach-Object {$AliasesToExport.Add("$($_.BaseName)")} | Out-Null
            }
        }
    }

    New-ModuleManifest -Path $psd1Location `
    -NestedModules $NestedModules `
    -FunctionsToExport $FunctionsToExport `
    -AliasesToExport $AliasesToExport `
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