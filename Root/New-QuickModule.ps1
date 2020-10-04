function New-QuickModule {
    param(
        [Parameter(Mandatory=$true)][string] $QuickModule
    )
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"

    $ModuleDirectory = "$QuickPackageModuleContainerPath\$QuickModule"
    $ModuleFile = "$ModuleDirectory\$QuickModule.psm1";
    $ModuleDeclarationFile = "$ModuleDirectory\$QuickModule.psd1";
    
    if (!(Test-Path "$ModuleDirectory")) {
        New-Item "$ModuleDirectory" -ItemType Directory | Out-Null
    }
    if (!(Test-Path "$ModuleDirectory\Functions")) {
        New-Item "$ModuleDirectory\Functions" -ItemType Directory | Out-Null
    }
    if (!(Test-Path "$ModuleDirectory\Aliases")) {
        New-Item "$ModuleDirectory\Aliases" -ItemType Directory | Out-Null
    }

    if (!(Test-Path $ModuleFile)) {
        $ModuleFileContent = @'
$functions = Get-ChildItem $PSScriptRoot\Functions -Filter "*.ps1"
foreach($function in $functions) {
    $functionName = $function.BaseName;
    if (!$functionName.EndsWith('.Tests')) {
        . $PSScriptRoot\Functions\$function
    }
}

$aliases = Get-ChildItem $PSScriptRoot\Aliases -Filter "*.ps1"
foreach($alias in $aliases) {
    . $PSScriptRoot\Aliases\$alias
}
        
'@
        New-Item $ModuleFile | Out-Null
        Add-Content -Path $ModuleFile -Value $ModuleFileContent
    } else {
        Write-Output 'Module already exists.'
    }

    if (!(Test-Path $ModuleDeclarationFile)) {
        $currentPowershellVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
        New-ModuleManifest -Path $ModuleDeclarationFile `
            -Author 'TODO' `
            -Description 'TODO' `
            -RootModule "$QuickModule.psm1" `
            -ModuleVersion '0.0.1' `
            -PowerShellVersion "$currentPowershellVersion" `
            -CompatiblePSEditions "Desktop" `
            -FunctionsToExport @() `
            -AliasesToExport @() `
            -CmdletsToExport @() `
    }

    #Export Member to Module
    $psd1Location = "$QuickPackageModuleFolder\$QuickPackageModuleName.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)
    $NewNestedModules = New-Object System.Collections.ArrayList($null)
    $NewNestedModules.AddRange($psd1.NestedModules)
    if (!$NewNestedModules.Contains("Modules\$QuickModule\$QuickModule")) {
        $NewNestedModules.Add("Modules\$QuickModule\$QuickModule") | Out-Null
    }
    $psd1.NestedModules = $NewNestedModules;
    Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
}