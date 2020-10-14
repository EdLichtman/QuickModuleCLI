function New-QuickModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule
    )
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI'"

    $ModuleDirectory = "$NestedModulesFolder\$NestedModule"
    $ModuleFile = "$ModuleDirectory\$NestedModule.psm1";
    $ModuleDeclarationFile = "$ModuleDirectory\$NestedModule.psd1";
    
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
    . $PSScriptRoot\Functions\$function
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
            -RootModule "$NestedModule.psm1" `
            -ModuleVersion '0.0.1' `
            -PowerShellVersion "$currentPowershellVersion" `
            -CompatiblePSEditions "Desktop" `
            -FunctionsToExport @() `
            -AliasesToExport @() `
            -CmdletsToExport @() `
    }

    Update-QuickModuleCLI
}