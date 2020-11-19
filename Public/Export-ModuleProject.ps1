function Export-ModuleProject {
    [CmdletBinding(
        PositionalBinding=$false,
        SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExportDestinationIsValid $_})]
        [string] $Destination
    )  

    $ModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    Copy-Item -Path $ModuleProjectLocation -Destination $Destination -Recurse;
}

Register-ArgumentCompleter -CommandName Export-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock