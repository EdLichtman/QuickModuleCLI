
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

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"

    function Add-ManifestProperties {
        [CmdletBinding()]
        param(
            [Hashtable] $BoundParameters,
            [Object] $ManifestProperties,
            [String[]] $Keys
        )
        foreach($Key in $Keys) {
            if ($BoundParameters.ContainsKey($Key)) { $ManifestProperties[$Key] = $BoundParameters[$Key] }
        }

    }

    #Remove Exported Member from Module
    $NestedModuleLocation = "$NestedModulesFolder\$NestedModule"
    if (!(Test-Path $NestedModuleLocation)) {
        Write-Output "No Quick Module found by the name '$NestedModule'"
        return;
    }

    $ManifestProperties = @{};
    Add-ManifestProperties $PSBoundParameters $ManifestProperties @('Author','CompanyName','Copyright','ModuleVersion','Description','Tags','ProjectUri','LicenseUri','IconUri','ReleaseNotes','HelpInfoUri')
    Update-QuickModule -NestedModule $NestedModule @ManifestProperties 

    $ModuleDirectories = $env:PSModulePath.Split(';')
    if ($ModuleDirectories -contains $Destination) {
        throw 'Cannot export module to a PSModule directory. Export-QuickModule should be used to export your Nested Module to be imported into the QuickModuleCLI package. If you wish to package the module for import as a separate module, use the command Split-QuickModule instead.'
    }

    Copy-Item -Path $NestedModuleLocation -Destination $Destination -Recurse;
}