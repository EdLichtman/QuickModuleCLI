using namespace System.Collections.Generic
using namespace System.IO
using namespace System.Management.Automation

<#FULLY TESTED#>
function Get-ModuleProjectLocation {
    param([Parameter(Mandatory=$true)][String]$ModuleProject)
    return "$ModuleProjectsFolder\$ModuleProject"
}

<#FULLY TESTED#>
function Get-ValidModuleProjects {
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

<#FULLY TESTED#>
function Get-ValidModuleProjectNames {
    [OutputType([Array])]
    $ProjectNames = @()
    (Get-ValidModuleProjects) | 
    ForEach-Object {
        $ProjectNames += "$($_.Name)"
    };
    return $ProjectNames
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
    
    $FunctionsFolder = Get-ModuleProjectFunctionsFolder -ModuleProject $ModuleProject
    if (!(Test-Path $FunctionsFolder)) {
        throw [ItemNotFoundException] "Module does not exist by the name '$ModuleProject'"
    }
    return @(Get-ChildItem ($FunctionsFolder))
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

    New-Item -Path $ModuleFunctionPath -ItemType File
    $functionContent = $Text;
    if (!$Raw) {
        $functionContent = @"
function $CommandName {
    $Text
}
"@
    }
    
    Add-Content -Path $ModuleFunctionPath -Value $functionContent
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
    
    $AliasesFolder = Get-ModuleProjectAliasesFolder -ModuleProject $ModuleProject
    if (!(Test-Path $AliasesFolder)) {
        throw [ItemNotFoundException] "Module does not exist by the name '$ModuleProject'"
    }
    return @(Get-ChildItem ($AliasesFolder))
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

    New-Item -Path $ModuleAliasPath -ItemType File
    $aliasContent = "Set-Alias $Alias $CommandName"
    
    Add-Content -Path $ModuleAliasPath -Value $aliasContent
}

<#SOME TESTING DONE#>
function Get-ModuleProjectCommand {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ModuleProject -CommandName $CommandName
    $AliasPath = Get-ModuleProjectAliasPath -ModuleProject $ModuleProject -CommandName $CommandName

    if (Test-Path $FunctionPath) {
        return ('Function', (Get-Item $FunctionPath))
    }
    if (Test-Path $AliasPath) {
        return ('Alias', (Get-Item $AliasPath))
    }
    throw [System.InvalidOperationException] "No command exists named $CommandName in $ModuleProject!"
}

<#SOME TESTING DONE#>
function Get-ModuleProjectCommandDefinition {
    param(
        [Parameter(Mandatory=$true)][String]$ModuleProject,
        [Parameter(Mandatory=$true)][String]$CommandName
    )
    $CommandType, $Command = Get-ModuleProjectCommand -ModuleProject $ModuleProject -CommandName $CommandName

    . "$($Command.FullName)"
    $CommandName = $Command.BaseName
    $CommandDefinition = ""
    if ($CommandType -EQ 'Function') {
        # Using AST because -ExpandProperty Definition adds a /r/n to the beginning and end of the line 
        # and instead of hoping all powershell versions work the same way, this is safer than manipulating 
        # any text.
        $CommandDefinition = (Get-ChildItem function:\$CommandName).ScriptBlock.Ast.Body.EndBlock.ToString()
    } elseif($CommandType -EQ 'Alias') {
        $CommandDefinition = (Get-ChildItem alias:\$CommandName).Definition
    }
    
    return ($CommandType, $CommandDefinition)
}

<#FULLY TESTED#>
function Get-ApprovedVerbs {
    $ApprovedVerbs = [HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) `
    | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;

    return $ApprovedVerbs;
}

<#TODO: MOVE THIS TO NEW PRIVATE FUNCTIONS FILE#>
function Wait-ForKeyPress {
    Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

<#TODO: MOVE THIS TO NEW PRIVATE FUNCTIONS FILE#>
function Open-PowershellEditor{ 
    param([String]$Path)
    powershell.exe $Path
}