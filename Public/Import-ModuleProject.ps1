
function Import-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectForImportIsValid $_})]
        [string] $Path
    )

    Copy-Item -Path $Path -Destination $ModuleProjectsFolder -Recurse;

    Import-Module $BaseModuleName -Force
}