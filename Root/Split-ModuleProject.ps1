function Split-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)][string] $NestedModule,
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

    Assert-CanCreateModule -NestedModule $NestedModule #todo: Fix this, it keeps erroring because it checks to see if Module already exists, which by default it does, and that's a problem here.

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

    if (!(Test-Path "$ModulesDirectory\$NestedModule")) {
        New-Item -Path "$ModulesDirectory\$NestedModule" -ItemType Directory
    }
    Move-Item -Path $NestedModuleDirectory -Destination $ModulesDirectory;

    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -force
}