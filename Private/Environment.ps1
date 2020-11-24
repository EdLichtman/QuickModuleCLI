using namespace System.Collections.Generic
using namespace System.IO
using namespace System.Management.Automation
<#TODO: CacheBusting Logic on certain functions, such as Rename-ModuleCommand. 
Right now, Rename-ModuleCommand gets the already existing FunctionNames#>

<#TODO: Test#>
function GetFunctionDefinition {
    param(
        [Parameter(Mandatory=$true)][String]$CommandName
    )
    
    $Definition = (Get-ChildItem function:\$CommandName).ScriptBlock
    return @"
{
    $Definition
}
"@
}
<#TODO: Test#>
function GetAliasDefinition {
    param(
        [Parameter(Mandatory=$true)][String]$CommandName
    )
    return (Get-ChildItem alias:\$CommandName).Definition
}

<#FULLY TESTED#>
function GetValidModuleProject {
    return Get-ChildItem ($ModuleProjectsFolder) | 
    Where-Object {
        $files = Get-ChildItem $_.FullName -File | Select-Object -Property Name
        $directories = Get-ChildItem $_.FullName -Directory | Select-Object -Property Name
        $ModuleName = $_.BaseName;
        return $files -and `
            (
                $files -match "$ModuleName.psd1" -and `
                $files -match "$ModuleName.psm1"
            ) -and `
            $directories -and `
            (
                $directories -match "Functions" -and `
                $directories -match "Aliases"
            )

    }
}

function GetCommandEnvironmentVariables {
    #Todo: Replace many instances of Get-ChildItem and Get-ValidModuleProject with this to save on processing
    
    $_ValidModuleProjects = (GetValidModuleProject)
    $_ModuleProjects = [Dictionary[String, List[String]]]::new()
    $_ModuleProjectInfos = [Dictionary[String, FileSystemInfo]]::new()
    $_ModuleProjectCommands = [Dictionary[String, FileSystemInfo]]::new()
    $_ModuleProjectCommandFiles = [Dictionary[String, FileSystemInfo]]::new()
    $_ModuleProjectCommandDefinitions = [Dictionary[String,String]]::new()
    $_ModuleProjectCommandTypes = [Dictionary[String,String]]::new()

    foreach($_ModuleProject in $_ValidModuleProjects) {
        $_ModuleProjects[$_ModuleProject.Name] = [List[String]]::new()
        $_ModuleProjectInfos[$_ModuleProject.Name] = $_ModuleProject

        $_ModuleProjectFunctions = (Get-ChildItem "$($_ModuleProject.FullName)\Functions")
        foreach ($_Function in $_ModuleProjectFunctions) {
            $_FunctionName = $_Function.BaseName

            $_ModuleProjects[$_ModuleProject.Name].Add($_FunctionName)
            $_ModuleProjectCommands[$_FunctionName] = $_ModuleProject
            $_ModuleProjectCommandFiles[$_FunctionName] = $_Function
            $_ModuleProjectCommandDefinitions[$_FunctionName] = Get-Content -Path $_Function.FullName -Raw
            $_ModuleProjectCommandTypes[$_FunctionName] = 'Function'
        }

        $_ModuleProjectAliases = (Get-ChildItem "$($_ModuleProject.FullName)\Aliases")
        foreach ($_Alias in $_ModuleProjectAliases) {
            $_AliasName = $_Alias.BaseName
            . $_Alias.FullName

            $_ModuleProjects[$_ModuleProject.Name].Add($_AliasName)
            $_ModuleProjectCommands[$_AliasName] = $_ModuleProject
            $_ModuleProjectCommandFiles[$_AliasName] = $_Alias
            $_ModuleProjectCommandDefinitions[$_AliasName] = GetAliasDefinition -CommandName $_AliasName
            $_ModuleProjectCommandTypes[$_AliasName] = 'Alias'
        }
    }
    return $_ModuleProjects, $_ModuleProjectInfos, $_ModuleProjectCommands, $_ModuleProjectCommandFiles, $_ModuleProjectCommandTypes, $_ModuleProjectCommandDefinitions
}
function GetDefinitionForCommand {
    param(
        [Parameter()][String] $CommandName,
        [Parameter()][String] $NewCommandName
    )
    if (!$_ModuleProjectCommandDefinitions) {
        if ($IsProduction) {
            throw 'This should be cached. If you''re seeing this, the Module would be running super slowly'
        }
        $_, $_, $_,$_,$_,$_ModuleProjectCommandDefinitions = (GetCommandEnvironmentVariables)
    }

    if ($NewCommandName) {
        return $_ModuleProjectCommandDefinitions[$CommandName] -replace $CommandName, $NewCommandName
    }
    return $_ModuleProjectCommandDefinitions[$CommandName]
}
function GetFileForCommand {
    param(
        [Parameter()][String] $CommandName
    )
    if (!$_ModuleProjectCommandFiles) {
        if ($IsProduction) {
            throw 'This should be cached. If you''re seeing this, the Module would be running super slowly'
        }
        $_, $_, $_,$_ModuleProjectCommandFiles,$_,$_ = (GetCommandEnvironmentVariables)
    }

    return $_ModuleProjectCommandFiles[$CommandName]
}
function GetModuleProjectTypeForCommand {
    param(
        [Parameter()][String] $CommandName
    )
    if (!$_ModuleProjectCommandTypes) {
        if ($IsProduction) {
            throw 'This should be cached. If you''re seeing this, the Module would be running super slowly'
        }
        $_, $_, $_,$_,$_ModuleProjectCommandTypes,$_ = (GetCommandEnvironmentVariables)
    }

    return $_ModuleProjectCommandTypes[$CommandName]
}
function GetModuleProjectForCommand {
    param(
        [Parameter()][String] $CommandName
    )

    if (!$_ModuleProjectCommands) {
        if ($IsProduction) {
            throw 'This should be cached. If you''re seeing this, the Module would be running super slowly'
        }
        $_, $_, $_ModuleProjectCommands,$_,$_,$_ = (GetCommandEnvironmentVariables)
    }
    
    return $_ModuleProjectCommands[$CommandName]
}

function GetModuleProjectInfo {
    param(
        [Parameter()][String] $ModuleProject
    )

    if (!$_ModuleProjectInfos) {
        if ($IsProduction) {
            throw 'This should be cached. If you''re seeing this, the Module would be running super slowly'
        }
        $_, $_ModuleProjectInfos, $_,$_,$_,$_ = (GetCommandEnvironmentVariables)
    }

    if ($ModuleProject) {
        return $_ModuleProjectInfos[$ModuleProject]
    }
    return $_ModuleProjectInfos.Values
}

function GetCommandsInModuleProject {
    param(
        [Parameter()][String] $ModuleProject
    )

    if (!$_ModuleProjects) {
        if ($IsProduction) {
            throw 'This should be cached. If you''re seeing this, the Module would be running super slowly'
        }
        $_ModuleProjects, $_, $_,$_,$_,$_ = (GetCommandEnvironmentVariables)
    }

    if ($ModuleProject) {
        return $_ModuleProjects[$ModuleProject]
    }
    $ReturnValue = @()
    foreach($_ModuleProject in $_ModuleProjects.Values) {
        $ReturnValue += $_ModuleProject
    }
    return $ReturnValue
}



<#FULLY TESTED - DON"T TOUCH NEEDED FOR NEW #>
function Get-ModuleProjectLocation {
    param([Parameter(Mandatory=$true)][String]$ModuleProject)
    return "$ModuleProjectsFolder\$ModuleProject"
}


<#FULLY TESTED#>
function Get-ModuleProjectFunctionsFolder {
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ModuleProject
        )
    $ModuleLocation = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    return "$ModuleLocation\Functions"
}

<#FULLY TESTED#>
function Get-ModuleProjectFunctions {
    [OutputType([FileInfo[]])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ModuleProject
        )
    
    $Commands = GetCommandsInModuleProject -ModuleProject $ModuleProject 
    foreach($CommandName in $Commands) {
        $CommandType = GetModuleProjectTypeForCommand -CommandName $CommandName
        if ($CommandType -eq 'Function') {
            GetFileForCommand -CommandName $CommandName
        }
    }
}

<#FULLY TESTED#>
function Get-ModuleProjectFunctionNames {
    [OutputType([String[]])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ModuleProject
        )
    $Functions = Get-ModuleProjectFunctions -ModuleProject $ModuleProject
    return $Functions.BaseName
}

<#FULLY TESTED#>
function Get-ModuleProjectFunctionPath {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $FunctionsLocation = Get-ModuleProjectFunctionsFolder -ModuleProject $ModuleProject
    return "$FunctionsLocation\$CommandName.ps1"
}

<#FULLY TESTED#>
function New-ModuleProjectFunction {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$CommandName,
        [Parameter(Mandatory=$false)][String]$Text,
        [Switch] $Raw
        )
        
    $ModuleProjectPath = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    if (!(Test-Path ($ModuleProjectPath))) {
        throw [System.ArgumentException] "Module does not exist by the name '$moduleProject'"
    }

    $ModuleFunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ModuleProject -CommandName $CommandName
    if (Test-Path ($ModuleFunctionPath)) {
        throw [System.ArgumentException] "Function $CommandName already exists in $ModuleProject"
    }

    New-Item -Path $ModuleFunctionPath -ItemType File | Out-Null
    $functionContent = $Text;
    if (!$Raw) {
        $functionContent = @"
function $CommandName {
    $Text
}
"@
    }
    
    [IO.File]::WriteAllText($ModuleFunctionPath, $functionContent ,[Text.Encoding]::UTF8)
}

<#FULLY TESTED#>
function Get-ModuleProjectAliasesFolder {
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ModuleProject
        )
    $ModuleLocation = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    return "$ModuleLocation\Aliases"
}

<#FULLY TESTED#>
function Get-ModuleProjectAliases {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ModuleProject
        )
    
        $Commands = GetCommandsInModuleProject -ModuleProject $ModuleProject 
        foreach($CommandName in $Commands) {
            $CommandType = GetModuleProjectTypeForCommand -CommandName $CommandName
            if ($CommandType -eq 'Alias') {
                GetFileForCommand -CommandName $CommandName
            }
        }
}

<#FULLY TESTED#>
function Get-ModuleProjectAliasNames {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ModuleProject
        )
    $Aliases = Get-ModuleProjectAliases -ModuleProject $ModuleProject
    return $Aliases.BaseName
}

<#FULLY TESTED#>
function Get-ModuleProjectAliasPath {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $AliasesLocation = Get-ModuleProjectAliasesFolder -ModuleProject $ModuleProject
    return "$AliasesLocation\$CommandName.ps1"
}

<#FULLY TESTED#>
function New-ModuleProjectAlias {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$Alias,
        [Parameter(Mandatory=$true)][String]$CommandName
        )

    $ModuleProjectPath = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    if (!(Test-Path ($ModuleProjectPath))) {
        throw [System.ArgumentException] "Module does not exist by the name '$ModuleProject'"
    }

    $ModuleAliasPath = Get-ModuleProjectAliasPath -ModuleProject $ModuleProject -CommandName $Alias
    if (Test-Path ($ModuleAliasPath)) {
        throw [System.ArgumentException] "Alias $Alias already exists in $ModuleProject"
    }

    New-Item -Path $ModuleAliasPath -ItemType File | Out-Null
    $aliasContent = "Set-Alias $Alias $CommandName"
    
    Add-Content -Path $ModuleAliasPath -Value $aliasContent | Out-Null
}

<#TODO: Test#>
function Remove-ModuleProjectCommand {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$CommandName
    )

    $Command = (GetFileForCommand -CommandName $CommandName)
    Remove-Item $Command.FullName
}
<#TODO: Test#> 
function Remove-ModuleProjectFolder {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject
    )

    $ModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $ModuleProject
    $Continue = Confirm-Choice -Title 'Removing Module...' -Prompt "Removing '$ModuleProject' located at '$ModuleProjectLocation'. Are you sure you wish to proceed?"
    if ($Continue) {
        Remove-Item $ModuleProjectLocation -Recurse
    }
}

<#FULLY TESTED#>
function Get-ApprovedVerbs {
    $ApprovedVerbs = [HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) `
    | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;

    return $ApprovedVerbs;
}

<#TODO: Find a new place for this and Make Tests#>
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
    
    $ManifestProperties = Get-ReducedPopulatedHashtable -InputTable $PSBoundParameters `
        -Keys @(
        "Author",
        "Description",
        "CompanyName",
        "Copyright",
        "ModuleVersion",
        "HelpInfoUri",
        "RootModule",
        "FunctionsToExport",
        "AliasesToExport"
        "Tags",
        "ProjectUri",
        "LicenseUri",
        "IconUri",
        "ReleaseNotes"
    )
   
    $ExistingProperties = Get-ReducedPopulatedHashTable -InputTable $psd1 `
        -Keys @(
            "Author",
            "Description",
            "CompanyName",
            "Copyright",
            "ModuleVersion",
            "HelpInfoUri",
            "RootModule",
            "FunctionsToExport",
            "AliasesToExport"
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

    $PrivateData = Get-ReducedPopulatedHashTable -InputTable $psd1.PrivateData.PSData `
        -Keys @(
            "Tags",
            "ProjectUri",
            "LicenseUri",
            "IconUri",
            "ReleaseNotes"
        )
    
    foreach($Key in $ExistingProperties.Keys) {
        if (!$ManifestProperties.ContainsKey($Key)){
            $ManifestProperties[$Key] = $ExistingProperties[$Key]
        }
    }

    foreach($Key in $PrivateData.Keys) {
        if (!$ManifestProperties.ContainsKey($Key)){
            $ManifestProperties[$Key] = $PrivateData[$Key]
        }
    }

    New-ModuleManifest -Path $psd1Location @ManifestProperties
}

