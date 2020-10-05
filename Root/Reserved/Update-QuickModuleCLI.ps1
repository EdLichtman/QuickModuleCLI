function Update-QuickModuleCLI {
    Invoke-Expression ". '$PSScriptRoot\Get-QuickEnvironment.ps1'"
    $psd1Location = "$QuickPackageModuleFolder\$QuickPackageModuleName.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)

    $FunctionsToExport = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ChildItem "$QuickHelpersRoot" -File
    if ($Functions) {
        $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
    }

    $NestedModules = New-Object System.Collections.ArrayList($null)
    foreach($Module in Get-ChildItem $QuickPackageModuleContainerPath) {
        $ModuleName = $Module.BaseName;
        $NestedModules.Add("Modules\$ModuleName\$ModuleName") | Out-Null
        $QuickModuleLocation = "$QuickPackageModuleContainerPath\$ModuleName"
        if (Test-Path "$QuickModuleLocation\Functions") {
            $Functions = Get-ChildItem "$QuickModuleLocation\Functions" -File;
            if ($Functions) {
                $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
            }
        }
    }
        
    $psd1.NestedModules = $NestedModules;
    $psd1.FunctionsToExport = $FunctionsToExport;

    Set-Content $psd1Location (ConvertTo-PSON $psd1)    
}