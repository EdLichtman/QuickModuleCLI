
function Import-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectForImportIsValid $_})]
        [string] $Path#, 

        # [Parameter()]
        # [Switch] $AllInDirectory # Todo: add ability to import all
    )

    Copy-Item -Path $Path -Destination $ModuleProjectsFolder -Recurse;

    Import-Module $BaseModuleName -Force -Global
}