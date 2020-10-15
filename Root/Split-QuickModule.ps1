function Split-QuickModule {
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

    Assert-CanCreateModule -NestedModule $NestedModule

    $NestedModuleDirectory = Get-NestedModuleLocation -NestedModule $NestedModule
    $psd1Location = "$NestedModuleDirectory\$NestedModule.psd1"

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

    Edit-ModuleManifest -psd1Location $psd1Location @ModuleManifestParameters 

    $ModuleDirectories = $env:PSModulePath.Split(';')
    $ModulesDirectory = $ModuleDirectories | Where-Object {$_.StartsWith((Split-Path $Profile))}

    Move-Item -Path $NestedModuleLocation -Destination $ModulesDirectory;

    Update-QuickModuleCLI
    Import-Module $BaseModuleName -force
}