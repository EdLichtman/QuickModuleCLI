function Export-QuickModule {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)][string]
        $NestedModule,

        [Parameter(Mandatory=$true)][string]
        $Destination,

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
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"

    
    #Remove Exported Member from Module
    $NestedModuleLocation = "$NestedModulesFolder\$NestedModule"
    Assert-ModuleAlreadyExists $NestedModule

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

    Update-QuickModule -NestedModule $NestedModule @ModuleManifestParameters 

    $ModuleDirectories = $env:PSModulePath.Split(';')
    if ($ModuleDirectories -contains $Destination) {
        throw 'Cannot export module to a PSModule directory. Export-QuickModule should be used to export your Nested Module to be imported into the QuickModuleCLI package. If you wish to package the module for import as a separate module, use the command Split-QuickModule instead.'
    }

    Copy-Item -Path $NestedModuleLocation -Destination $Destination -Recurse;
}