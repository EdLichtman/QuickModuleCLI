function Rename-ModuleProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $NestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectDoesNotExist)})]
        [string] $DestinationNestedModule
    )

    Assert-CanCreateModule -NestedModule $NestedModule

    $NestedModuleDirectory = Get-NestedModuleLocation -NestedModule $NestedModule
    $DestinationModuleDirectory = Get-NestedModuleLocation -NestedModule $DestinationNestedModule
    Copy-Item -Path $NestedModuleDirectory -Destination $DestinationModuleDirectory -Recurse

    $DestinationPsd1Location = "$DestinationModuleDirectory\$DestinationNestedModule.psd1"
    Rename-Item -Path "$DestinationModuleDirectory\$NestedModule.psd1" -NewName $DestinationPsd1Location
    Rename-Item -Path "$DestinationModuleDirectory\$NestedModule.psm1" -NewName "$DestinationModuleDirectory\$DestinationNestedModule.psm1"

    Edit-ModuleManifest -psd1Location "$DestinationModuleDirectory\$DestinationNestedModule.psd1" -RootModule "$DestinationNestedModule.psm1"
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}