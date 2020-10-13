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

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI.ps1'"

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

    if ((Get-Module -ListAvailable $NestedModule)) {
        throw [System.ArgumentException] "A module is already available by the name '$NestedModule'. This module does not support clobber and Prefixes."
    }

    $ManifestProperties = @{};
    Add-ManifestProperties $PSBoundParameters $ManifestProperties @('Author','CompanyName','Copyright','ModuleVersion','Description','Tags','ProjectUri','LicenseUri','IconUri','ReleaseNotes','HelpInfoUri')
    Update-QuickModule -NestedModule $NestedModule @ManifestProperties 

    $ModuleDirectories = $env:PSModulePath.Split(';')
    $ModulesDirectory = $ModuleDirectories | Where-Object {$_.StartsWith((Split-Path $Profile))}

    Move-Item -Path $NestedModuleLocation -Destination $ModulesDirectory;

    Update-QuickModuleCLI

}