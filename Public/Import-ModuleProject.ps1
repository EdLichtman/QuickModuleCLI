
function Import-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)][string] $Path
    )

    $NestedModule = (Split-Path $Path -Leaf)
    throw [System.NotImplementedException]
    Assert-CanCreateModule -NestedModule $NestedModule

    if (!(Test-Path "$Path\$NestedModule.psd1") `
        -or !(Test-Path "$Path\$NestedModule.psm1") `
        -or !(Test-Path "$Path\Functions") `
        -or !(Test-Path "$Path\Aliases")) {
            #todo -- add more validation, like do all the functions and Aliases only hold 1 base function or alias? Does psd1 have DefaultPrefix?
            throw [System.ArgumentException] "This module is not supported for import by QuickModuleCLI"
        }

    Copy-Item -Path $Path -Destination $NestedModulesFolder -Recurse;

    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}