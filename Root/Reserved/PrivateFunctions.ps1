<# ENVIRONMENT VARIABLES #>
$BaseFolder =  "$PSScriptRoot\..\.."
$BaseModuleName = "QuickModuleCLI"
$NestedModulesFolder = "$BaseFolder\Modules"
$FunctionsFolder = "$BaseFolder\Root"
$PrivateFunctionsFolder = "$FunctionsFolder\Reserved"

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

<# Interpolations #>
function Get-NestedModuleLocation {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    return "$NestedModulesFolder\$NestedModule"
}

function Get-NestedModules {
    return Get-ChildItem $NestedModulesFolder
}

function Get-ModuleFunctionLocations {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return Get-ChildItem "$ModuleLocation\Functions"
}

function Get-ModuleAliasesLocations {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return Get-ChildItem "$ModuleLocation\Aliases"
}
function Get-ModuleFunctions {
    param([Parameter(Mandatory=$true)][String]$NestedModule)

    $NestedFunctions = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ModuleFunctionLocations -NestedModule $NestedModule
    if ($Functions) {
        $Functions | ForEach-Object {$NestedFunctions.Add("$($_.BaseName)")} | Out-Null
    }

    return $NestedFunctions
}

function Get-ModuleAliases {
    param([Parameter(Mandatory=$true)][String]$NestedModule)

    $NestedAliases = New-Object System.Collections.ArrayList($null)
    $Aliases = Get-ModuleAliasesLocations -NestedModule $NestedModule
    if ($Aliases) {
        $Aliases | ForEach-Object {$NestedAliases.Add("$($_.BaseName)")} | Out-Null
    }

    return $NestedAliases
}

function Get-ModuleFunctionsLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Functions\"
}

function Get-ModuleAliasesLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Aliases\"
}

function Get-ModuleFunctionLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Functions\$CommandName.ps1"
}

function Get-ModuleAliasLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Aliases\$CommandName.ps1"
}

<# Assertions: Throw Errors if False#>
function Assert-CanCreateModuleCommand {
    param(
        [Parameter(Mandatory=$true)][String]$CommandName,
        [Parameter(Mandatory=$true)][String]$NestedModule
    )

    $NestedModules = Get-NestedModules

    if (!(Test-Path (Get-NestedModuleLocation -NestedModule $NestedModule))) {
        throw "'$NestedModule' does not exist. Please use 'New-ModuleProject' to create it."
    }
    foreach($NestedModule in $NestedModules) {
        $Functions = Get-ModuleFunctionLocations -NestedModule $NestedModule
        $Aliases = Get-ModuleAliasesLocations -NestedModule $NestedModule
        foreach($Function in $Functions) {
            if ($Function.BaseName -eq $CommandName) {
                throw "'$CommandName' already exists as a function in '$NestedModule'! Cannot create command with existing name, to prevent clashing."
            }
        }
        foreach($Alias in $Aliases) {
            if ($Alias.BaseName -eq $CommandName) {
                throw "'$CommandName' already exists as an alias in '$NestedModule'! Cannot create command with existing name, to prevent clashing."
            }
        }
    } 
}

function Assert-CanFindCommand {       
    param([Parameter(Mandatory=$true)][String]$CommandName) 
    Get-Command $CommandName -ErrorAction 'Stop' | Out-Null
}

function Assert-CanFindModuleCommand {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $Function = "$NestedModulesFolder\$NestedModule\Functions\$CommandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$CommandName.ps1"

    if (!(Test-Path $Function) -and !(Test-Path $Alias)) {
        throw [System.Management.Automation.ItemNotFoundException]"Command '$SourceCommandName' not found."
    }
}

function Assert-CanCreateModule {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    if ((Test-Path (Get-NestedModuleLocation -NestedModule $NestedModule))) {
        throw [System.ArgumentException] "A nested QuickModuleCLI Module is already available by the name '$NestedModule'. This module does not support clobber and Prefixes."
    }
    #todo: Better verbiage
    if ((Get-Module -ListAvailable $NestedModule)) {
        throw [System.ArgumentException] "An installed module is already available by the name '$NestedModule'. This module does not support clobber and Prefixes."
    }
}

function Assert-ModuleAlreadyExists {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    $NestedModuleLocation = "$NestedModulesFolder\$NestedModule"
    if (!(Test-Path $NestedModuleLocation)) {
        throw [ArgumentException]"No Quick Module found by the name '$NestedModule'"
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

function Register-SubModuleArgumentCompleter {
    param(
        [String] $CommandName
    )
    $ParameterName = 'NestedModule'
    if ((Get-Command $CommandName).Parameters.Keys.Contains($ParameterName)) {
        $ScriptBlock = {Get-NestedModules | Select-Object -ExpandProperty Name}
        
        Register-ArgumentCompleter -CommandName $CommandName -ParameterName $ParameterName -ScriptBlock $ScriptBlock
    }
}