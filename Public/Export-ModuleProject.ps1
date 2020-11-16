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
        [ValidateScript({ValidateModuleProjectExportDestinationIsValid $_})]
        [string] $Destination,
        
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
    $ModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $ModuleProject

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

    Update-ModuleProject -ModuleProject $ModuleProject @ModuleManifestParameters 

    Copy-Item -Path $ModuleProjectLocation -Destination $Destination -Recurse;
}

Register-ArgumentCompleter -CommandName Export-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock