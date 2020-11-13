function Export-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)][string] $Destination,
        [String] $Author,
        [String] $CompanyName,
        [String] $Copyright,
        [Version] $ModuleVersion,
        [String] $Description,
        [String[]] $Tags,
        [Uri] $ProjectUri,
        [Uri] $LicenseUri,
        [Uri] $IconUri,
        [String] $ReleaseNotes,
        [String] $HelpInfoUri
    )  
    $NestedModuleLocation = Get-ModuleProjectLocation -ModuleProject $NestedModule

    $ModuleManifestParameters = @{}
    Add-InputParametersToObject -BoundParameters $PSBoundParameters `
        -ObjectToPopulate $ModuleManifestParameters `
        -Keys @(
            'Author',
            'CompanyName',
            'Copyright',
            'ModuleVersion',
            'Description',
            'Tags',
            'ProjectUri',
            'LicenseUri',
            'IconUri',
            'ReleaseNotes',
            'HelpInfoUri'
        )

    Update-ModuleProject -NestedModule $NestedModule @ModuleManifestParameters 

    $ModuleDirectories = $env:PSModulePath.Split(';')
    if ($ModuleDirectories -contains $Destination) {
        throw 'Cannot export module to a PSModule directory. Export-ModuleProject should be used to export your Nested Module to be imported into the QuickModuleCLI package. If you wish to package the module for import as a separate module, use the command Split-ModuleProject instead.'
    }

    Copy-Item -Path $NestedModuleLocation -Destination $Destination -Recurse;
}

Register-ArgumentCompleter -CommandName Export-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock