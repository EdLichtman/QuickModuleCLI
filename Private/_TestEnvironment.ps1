function Get-SandboxBaseFolder { return "$PSScriptRoot\..\TestSandbox"; }
function Get-SandboxNestedModulesFolder { return "$(Get-SandboxBaseFolder)\Modules"; }
function Get-SandboxFunctionsFolder { return "$(Get-SandboxBaseFolder)\Public"; }
function Get-SandboxPrivateFunctionsFolder { return "$(Get-SandboxBaseFolder)\Private" }

function Get-ArgumentCompleter {
    <#
    .SYNOPSIS
        Get custom argument completers registered in the current session.
    .DESCRIPTION
        Get custom argument completers registered in the current session.
        
        By default Get-ArgumentCompleter lists all of the completers registered in the session.
    .EXAMPLE
        Get-ArgumentCompleter
        
        Get all of the argument completers for PowerShell commands in the current session.
    .EXAMPLE
        Get-ArgumentCompleter -CommandName Invoke-ScriptAnalyzer
        
        Get all of the argument completers used by the Invoke-ScriptAnalyzer command.
    .EXAMPLE
        Get-ArgumentCompleter -Native
        Get all of the argument completers for native commands in the current session.
    .LINK
        https://gist.github.com/indented-automation/26c637fb530c4b168e62c72582534f5b
    #>

    [CmdletBinding(DefaultParameterSetName = 'PSCommand')]
    param (
        # Filter results by command name.
        [String]$CommandName = '*',

        # Filter results by parameter name.
        [Parameter(ParameterSetName = 'PSCommand')]
        [String]$ParameterName = '*',

        # Get argument completers for native commands.
        [Parameter(ParameterSetName = 'Native')]
        [Switch]$Native
    )

    $getExecutionContextFromTLS = [PowerShell].Assembly.GetType('System.Management.Automation.Runspaces.LocalPipeline').GetMethod(
        'GetExecutionContextFromTLS',
        [System.Reflection.BindingFlags]'Static,NonPublic'
    )
    $internalExecutionContext = $getExecutionContextFromTLS.Invoke(
        $null,
        [System.Reflection.BindingFlags]'Static, NonPublic',
        $null,
        $null,
        $psculture
    )

    if ($Native) {
        $argumentCompletersProperty = $internalExecutionContext.GetType().GetProperty(
            'NativeArgumentCompleters',
            [System.Reflection.BindingFlags]'NonPublic, Instance'
        )
    } else {
        $argumentCompletersProperty = $internalExecutionContext.GetType().GetProperty(
            'CustomArgumentCompleters',
            [System.Reflection.BindingFlags]'NonPublic, Instance'
        )
    }

    $argumentCompleters = $argumentCompletersProperty.GetGetMethod($true).Invoke(
        $internalExecutionContext,
        [System.Reflection.BindingFlags]'Instance, NonPublic, GetProperty',
        $null,
        @(),
        $psculture
    )
    foreach ($completer in $argumentCompleters.Keys) {
        $name, $parameter = $completer -split ':'

        if ($name -like $CommandName -and $parameter -like $ParameterName) {
            [PSCustomObject]@{
                CommandName   = $name
                ParameterName = $parameter
                Definition    = $argumentCompleters[$completer]
            }
        }
    }
}
function Add-TestModule {
    param(
        [String] $Name,
        [Switch] $IncludeManifest,
        [Switch] $IncludeRoot,
        [Switch] $IncludeFunctions,
        [Switch] $IncludeAliases
    )

    $TestModuleDirectory = "$(Get-SandboxNestedModulesFolder)\$Name"
    New-Item -Path $TestModuleDirectory -ItemType Directory

    if ($IncludeManifest) {
        $TestModuleManifest = "$TestModuleDirectory\$Name.psd1"
        New-ModuleManifest -Path $TestModuleManifest
    }

    if ($IncludeRoot) {
        $TestModuleRoot = "$TestModuleDirectory\$Name.psm1"
        New-Item -Path $TestModuleRoot
    }

    if ($IncludeFunctions) {
        $FunctionsFolder = "$TestModuleDirectory\Functions"
        New-Item -Path $FunctionsFolder -ItemType Directory
    }

    if ($IncludeAliases) {
        $AliasesFolder = "$TestModuleDirectory\Aliases"
        New-Item -Path $AliasesFolder -ItemType Directory
    }
}

function Add-TestFunction {
    param(
        [String] $ModuleName,
        [String] $FunctionName,
        [String] $FunctionText
    )

    $TestModuleDirectory = "$(Get-SandboxNestedModulesFolder)\$ModuleName"
    if (!(Test-Path $TestModuleDirectory)) {
        throw [System.Management.Automation.ItemNotFoundException] "Test Setup failed. Please add '$ModuleName' Module first"
    }
    
    $TestFunctionsDirectory = "$TestModuleDirectory\Functions"
    if (!(Test-Path $TestFunctionsDirectory)) {
        throw [System.Management.Automation.ItemNotFoundException] "Test Setup failed. Please add FunctionsFolder to '$ModuleName' Module first"
    }

    $FunctionPath = "$TestFunctionsDirectory\$FunctionName.ps1"
    New-Item $FunctionPath -ItemType File -Force;
    Add-Content $FunctionPath @"
function $functionName {
    $FunctionText
}
"@
}

function Add-TestAlias {
    param(
        [String] $ModuleName,
        [String] $AliasName
    )

    $TestModuleDirectory = "$(Get-SandboxNestedModulesFolder)\$ModuleName"
    if (!(Test-Path $TestModuleDirectory)) {
        throw [System.Management.Automation.ItemNotFoundException] "Test Setup failed. Please add '$ModuleName' Module first"
    }
    
    $TestAliasesDirectory = "$TestModuleDirectory\Aliases"
    if (!(Test-Path $TestAliasesDirectory)) {
        throw [System.Management.Automation.ItemNotFoundException] "Test Setup failed. Please add AliasesFolder to '$ModuleName' Module first"
    }

    $AliasPath = "$TestAliasesDirectory\$AliasName.ps1"
    New-Item $AliasPath -ItemType File -Force;
    Add-Content $AliasPath "Set-Alias $AliasName Test-$AliasName"
}

function Get-MockFileInfo {
    [CmdletBinding(PositionalBinding=$False)]
    param(
        [String]$BaseName,
        [Switch]$Directory
    )
    $CustomObject = [Object]::new()
    $CustomObject | Add-Member -NotePropertyName 'BaseName' -NotePropertyValue $BaseName
    $Name = if ($Directory) {$BaseName} else {"$BaseName.ps1"}
    $CustomObject | Add-Member -NotePropertyName 'Name' -NotePropertyValue $Name
    return $CustomObject
}

#BeforeEach
function New-Sandbox {
    New-Item -Path (Get-SandboxBaseFolder) -ItemType Directory
    New-Item -Path (Get-SandboxNestedModulesFolder) -ItemType Directory 
    New-Item -Path (Get-SandboxFunctionsFolder) -ItemType Directory
    New-Item -Path (Get-SandboxPrivateFunctionsFolder) -ItemType Directory
}

#AfterEach
function Remove-Sandbox {
    $SandboxBase = Get-SandboxBaseFolder
    if (![String]::IsNullOrWhiteSpace($SandboxBase)) {
        if (Test-Path $SandboxBase) {
            Remove-Item -Path $SandboxBase -Recurse -Force
        }
    } else {
        throw 'Scoping Exception! Get-SandboxBaseFolder is empty!'
    }
}