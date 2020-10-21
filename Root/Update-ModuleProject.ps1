
function Update-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $NestedModule,
        
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
    $NestedModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    $psd1Location = "$NestedModuleLocation\$NestedModule.psd1"

    $FunctionsToExport = Get-ModuleFunctions -NestedModule $NestedModule
    $AliasesToExport = Get-ModuleAliases -NestedModule $NestedModule
    
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