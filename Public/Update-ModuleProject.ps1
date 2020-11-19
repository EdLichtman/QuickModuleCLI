
function Update-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
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
    
    $ModuleManifestParameters = Get-ReducedPopulatedHashtable -InputTable $PSBoundParameters `
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

    $ModuleManifestParameters.FunctionsToExport = Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject
    $ModuleManifestParameters.AliasesToExport = Get-ModuleProjectAliasNames -ModuleProject $ModuleProject

    Edit-ModuleManifest -psd1Location $psd1Location @ModuleManifestParameters
}
Register-ArgumentCompleter -CommandName Update-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock