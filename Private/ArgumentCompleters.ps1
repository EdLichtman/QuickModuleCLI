using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation 
using namespace System.Management.Automation.Language

function Get-ModuleProjectArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    $Choices = [List[String]]::new()
    Get-ValidModuleProjectNames | 
        Where-Object {$_ -like "$WordToComplete*"} | 
        ForEach-Object { $Choices.Add("$_") }
    if ($Choices) {
        return @($Choices)
    }
}

function Get-ApprovedVerbsArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    $Choices = [List[String]]::new()
    Get-ApprovedVerbs | 
        Where-Object {$_ -like "$WordToComplete*"} | 
        ForEach-Object { $Choices.Add("$_-") }
    return $Choices
}

function Get-CommandFromModuleArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )

    $ModuleProject = if ($FakeBoundParameters.Contains('ModuleProject')) {
        $FakeBoundParameters['ModuleProject']
    } elseif ($FakeBoundParameters.Contains('SourceModuleProject')) {
        $FakeBoundParameters['SourceModuleProject']
    }

    if($ModuleProject) {
        $ModuleProjects = Get-ValidModuleProjectNames 
        if ($ModuleProject -in $ModuleProjects) {
            $Functions = @(Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject | Where-Object {$_ -like "$WordToComplete*"})
            if ($Functions) {
                $Functions
            }
            $Aliases = @(Get-ModuleProjectAliasNames -ModuleProject $ModuleProject | Where-Object {$_ -like "$WordToComplete*"})
            if ($Aliases) {
                $Aliases
            }
        }
    }  
}

function Get-CommandFromOptionalModuleArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )

    $ModuleProject = if ($FakeBoundParameters.Contains('ModuleProject')) {
        $FakeBoundParameters['ModuleProject']
    } 

    $ModuleProjects = Get-ValidModuleProjectNames

    foreach($Module in $ModuleProjects) {
        if(!$ModuleProject -or ($ModuleProject -eq $Module)) {
            $Functions = @(Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject | Where-Object {$_ -like "$WordToComplete*"})
            if ($Functions) {
                $Functions
            }
            $Aliases = @(Get-ModuleProjectAliasNames -ModuleProject $ModuleProject | Where-Object {$_ -like "$WordToComplete*"})
            if ($Aliases) {
                $Aliases
            }
        }  
    }
}

<#TODO: Test#>
function Get-NewCommandFromModuleArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )

    $ModuleProject = if ($FakeBoundParameters.Contains('ModuleProject')) {
        $FakeBoundParameters['ModuleProject']
    } elseif ($FakeBoundParameters.Contains('SourceModuleProject')) {
        $FakeBoundParameters['SourceModuleProject']
    }

    $CommandName = if ($FakeBoundParameters.Contains('CommandName')) {
        $FakeBoundParameters['CommandName']
    } else {''}

    if($ModuleProject -and $CommandName) {
        $Choices = @()
        $ModuleProjects = Get-ValidModuleProjectNames 
        if ($ModuleProject -in $ModuleProjects) {
            $Functions = Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject | Where-Object {$_ -EQ $CommandName}
            if ($Functions) { 
                Get-ApprovedVerbs | 
                    Where-Object {$_ -like "$WordToComplete*"} | 
                    ForEach-Object { $Choices += @("$_-") }
             }

            return @($Choices)
        } 
    }  
}