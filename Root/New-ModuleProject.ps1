function New-ModuleProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule
    )
    Assert-CanCreateModule -NestedModule $NestedModule

    $ModuleDirectory = Get-NestedModuleLocation $NestedModule
    $ModuleFile = "$ModuleDirectory\$NestedModule.psm1";
    $ModuleDeclarationFile = "$ModuleDirectory\$NestedModule.psd1";
    $FunctionsDirectory = Get-ModuleFunctionsLocation -NestedModule $NestedModule
    $AliasesDirectory = Get-ModuleAliasesLocation -NestedModule $NestedModule
    
    New-Item "$ModuleDirectory" -ItemType Directory | Out-Null
    New-Item "$FunctionsDirectory" -ItemType Directory | Out-Null
    New-Item "$AliasesDirectory" -ItemType Directory | Out-Null

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


    Update-ModuleProjectCLI
}