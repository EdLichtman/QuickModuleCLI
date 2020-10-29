<# ENVIRONMENT VARIABLES #>

<# INTERNAL FUNCTIONS #>
function New-FileWithContent {
    param(  [String] $filePath,
            [String] $fileText,
            [Switch] $force)

    $continue = 0;
    if (Test-Path $filePath) {
        if (!$force) {
            $folderPath = Split-Path $filePath
            $fileName = Split-Path $filePath -Leaf
            $continue = $Host.UI.PromptForChoice("'$fileName' already exists at location $folderPath.", "Would you like to overwrite?", @('&Yes','&No'),1)
        }
       
        if ($continue -eq '0') {
            Remove-Item $filePath
        }
    } 

    if ($continue -eq '0') {
        New-Item -ItemType File -Force -Path $filePath | Out-null
    }
    if (Test-Path $filePath) {
        Add-Content -Path $filePath -Value $fileText 
    }
}


<# Utilities #>
function Add-InputParametersToObject {
    <#
.Synopsis
Given the $PSBoundParameters, an object to populate and a set of keys, 
this creates an object from the input parameters.
    #>
    param (
        [Hashtable] $BoundParameters,
        [Object] $ObjectToPopulate,
        [String[]] $Keys
    )
    foreach($Key in $Keys) {
        if ($BoundParameters.ContainsKey($Key)) { $ObjectToPopulate[$Key] = $BoundParameters[$Key] }
    }
}

function Edit-ModuleManifest {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [String]$psd1Location,
        [String]$Author,
        [String]$CompanyName,
        [String]$Copyright,
        [Version]$ModuleVersion,
        [String]$Description,
        $Tags,
        [Uri]$ProjectUri,
        [Uri]$LicenseUri,
        [Uri]$IconUri,
        [String]$ReleaseNotes,
        [String]$HelpInfoUri,
        [String]$RootModule,
        $FunctionsToExport,
        $AliasesToExport,
        $NestedModules
    ) 
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)
    
    function Add-ManifestProperties {
        param(
            [Hashtable] $BoundParameters,
            [Hashtable] $ExistingManifestProperties,
            [Object] $ManifestProperties,
            [String[]] $Keys
        )
        foreach($Key in $Keys) {
            if ($BoundParameters.ContainsKey($Key)) { $ManifestProperties[$Key] = $BoundParameters[$Key] }
            elseif($ExistingManifestProperties.ContainsKey($Key)) { $ManifestProperties[$Key] = $ExistingManifestProperties[$Key] }
        }
    }
    $ManifestProperties = @{
        Path = $psd1Location
    }
    Add-ManifestProperties -BoundParameters $PSBoundParameters -ExistingManifestProperties $psd1 -ManifestProperties $ManifestProperties `
        @(
            #Actually Passed in
            "Author",
            "Description",
            "CompanyName",
            "Copyright",
            "ModuleVersion",
            "HelpInfoUri",
            "RootModule",
            "FunctionsToExport",
            "AliasesToExport",
            "NestedModules",

            #Should exist only on psd1
            "PowerShellVersion",
            "CompatiblePSEditions",
            "CmdletsToExport",
            "VariablesToExport",
            "Guid",
            "ClrVersion",
            "DotNetFrameworkVersion",
            "PowerShellHostName",
            "PowerShellHostVersion",
            "RequiredModules",
            "TypesToProcess",
            "FormatsToProcess",
            "ScriptsToProcess",
            "RequiredAssemblies",
            "FileList",
            "ModuleList",
            "DscResourcesToExport"
        )

        Add-ManifestProperties -BoundParameters $PSBoundParameters -ExistingManifestProperties $psd1.PrivateData.PSData -ManifestProperties $ManifestProperties `
        @(
            "Tags",
            "ProjectUri",
            "LicenseUri",
            "IconUri",
            "ReleaseNotes"
        )
        
    New-ModuleManifest @ManifestProperties
}
function Update-ModuleProjectCLI {
    [CmdletBinding()]param()
    $psd1Location = "$BaseFolder\$BaseModuleName.psd1"

    $FunctionsToExport = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ChildItem "$FunctionsFolder" -File
    if ($Functions) {
        $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
    }

    $AliasesToExport = New-Object System.Collections.ArrayList($null)

    $NestedModules = New-Object System.Collections.ArrayList($null)
    foreach($Module in Get-ChildItem $NestedModulesFolder) {
        $ModuleName = $Module.BaseName;
        $NestedModules.Add("Modules\$ModuleName\$ModuleName") | Out-Null
        $QuickModuleLocation = "$NestedModulesFolder\$ModuleName"
        if (Test-Path "$QuickModuleLocation\Functions") {
            $Functions = Get-ChildItem "$QuickModuleLocation\Functions" -File;
            if ($Functions) {
                $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
            }
        }

        if (Test-Path "$QuickModuleLocation\Aliases") {
            $Aliases = Get-ChildItem "$QuickModuleLocation\Aliases" -File;
            if ($Aliases) {
                $Aliases | ForEach-Object {$AliasesToExport.Add("$($_.BaseName)")} | Out-Null
            }
        }
    }

    Edit-ModuleManifest -psd1Location $psd1Location -NestedModules $NestedModules -FunctionsToExport $FunctionsToExport -AliasesToExport $AliasesToExport
}