function Rename-ModuleProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $SourceModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectDoesNotExist $_})]
        [string] $DestinationModuleProject
    )

    $SourceModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $SourceModuleProject
    $DestinationModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $DestinationModuleProject

    Rename-Item -Path $SourceModuleProjectLocation -NewName $DestinationModuleProject
    Rename-Item -Path "$DestinationModuleProjectLocation\$SourceModuleProject.psd1" -NewName "$DestinationModuleProject.psd1"
    Rename-Item -Path "$DestinationModuleProjectLocation\$SourceModuleProject.psm1" -NewName "$DestinationModuleProject.psm1"

    Edit-ModuleManifest -psd1Location "$DestinationModuleProjectLocation\$DestinationModuleProject.psd1" -RootModule "$DestinationModuleProject.psm1"
    Import-Module $BaseModuleName -Force -Global
}

Register-ArgumentCompleter -CommandName Rename-ModuleProject -ParameterName SourceModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock