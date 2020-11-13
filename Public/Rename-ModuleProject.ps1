function Rename-ModuleProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter([ModuleProjectArgument])]
        [string] $NestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleProjectDoesNotExist()]
        [string] $DestinationNestedModule
    )

    $NestedModuleDirectory = Get-ModuleProjectLocation -ModuleProject $NestedModule
    $DestinationModuleDirectory = Get-ModuleProjectLocation -ModuleProject $DestinationNestedModule
    Copy-Item -Path $NestedModuleDirectory -Destination $DestinationModuleDirectory -Recurse

    $DestinationPsd1Location = "$DestinationModuleDirectory\$DestinationNestedModule.psd1"
    Rename-Item -Path "$DestinationModuleDirectory\$NestedModule.psd1" -NewName $DestinationPsd1Location
    Rename-Item -Path "$DestinationModuleDirectory\$NestedModule.psm1" -NewName "$DestinationModuleDirectory\$DestinationNestedModule.psm1"

    Edit-ModuleManifest -psd1Location "$DestinationModuleDirectory\$DestinationNestedModule.psd1" -RootModule "$DestinationNestedModule.psm1"
    #Import-Module $BaseModuleName -Force
}