
function Update-QuickModule {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)][string]
        $NestedModule,

        [String] 
        
        $Author,
        [String]

        $CompanyName,
        [String]

        $Copyright,
        [Version]

        $ModuleVersion,
        [String]

        $Description,
        [String[]]

        $Tags,
        [Uri]

        $ProjectUri,
        [Uri]

        $LicenseUri,
        [Uri]

        $IconUri,
        [String]

        $ReleaseNotes,
        [String]

        $HelpInfoUri
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
   
    Assert-ModuleAlreadyExists -NestedModule $NestedModule
    $NestedModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    $psd1Location = "$NestedModuleLocation\$NestedModule.psd1"

    $FunctionsToExport = Get-QuickFunctions -NestedModule $NestedModule
    $AliasesToExport = Get-QuickAliases -NestedModule $NestedModule
    
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