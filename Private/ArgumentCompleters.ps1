using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation 
using namespace System.Management.Automation.Language

function ModuleProjectArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    $Choices = [List[String]]::new()
    (GetModuleProjectInfo).Name | 
        Where-Object {$_ -like "$WordToComplete*"} | 
        ForEach-Object { $Choices.Add("$_") }
    if ($Choices) {
        return @($Choices)
    }
}

function ApprovedVerbsArgumentCompleter {
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

function CommandFromModuleArgumentCompleter {
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
        $ModuleProjectCommands = GetCommandsInModuleProject -ModuleProject $ModuleProject
        $Matching = $ModuleProjectCommands | Where-Object {$_ -like "$WordToComplete*"} 
        return $Matching
    }  
}

function CommandFromOptionalModuleArgumentCompleter {
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
    
    $ModuleProjectCommands = GetCommandsInModuleProject -ModuleProject $ModuleProject
    $Matching = $ModuleProjectCommands | Where-Object {$_ -like "$WordToComplete*"} 
    return $Matching
}

<#TODO: Test#>
function NewCommandFromModuleArgumentCompleter {
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
        $ModuleProjectCommands = GetCommandsInModuleProject -ModuleProject $ModuleProject
        $Matching = $ModuleProjectCommands | Where-Object {$_ -like "$WordToComplete*"} 
        if ($Matching -contains $CommandName) {
            $CommandType = GetModuleProjectTypeForCommand -CommandName $CommandName
            if ($CommandType -eq 'Function') {
                return ApprovedVerbsArgumentCompleter -WordToComplete $WordToComplete
            }
        }
        
    }  
}