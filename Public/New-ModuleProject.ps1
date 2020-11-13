function New-ModuleProject {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectDoesNotExist()]
        [string] $ModuleProject
    )

    $ModuleDirectory = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    $ModuleFile = "$ModuleDirectory\$ModuleProject.psm1";
    $ModuleDeclarationFile = "$ModuleDirectory\$ModuleProject.psd1";
    $FunctionsDirectory = Get-ModuleProjectFunctionsFolder -ModuleProject $ModuleProject
    $AliasesDirectory = Get-ModuleProjectAliasesFolder -ModuleProject $ModuleProject
    
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
        -RootModule "$ModuleProject.psm1" `
        -ModuleVersion '0.0.1' `
        -PowerShellVersion "$currentPowershellVersion" `
        -CompatiblePSEditions "Desktop" `
        -FunctionsToExport @('*-*') `
        -AliasesToExport @('*') `
        -CmdletsToExport @() `
}