
function Update-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $ModuleProject,
        
        [String]  $Author,
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
    $psd1Location = "$ModuleProjectLocation\$ModuleProject.psd1"

    $FunctionsToExport = Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject
    $AliasesToExport = Get-ModuleProjectAliasNames -ModuleProject $ModuleProject
    
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

    Edit-ModuleManifest -psd1Location $psd1Location @ModuleManifestParameters -FunctionsToExport $FunctionsToExport -AliasesToExport $AliasesToExport
}