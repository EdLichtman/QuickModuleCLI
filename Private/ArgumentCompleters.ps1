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
    if (!$Choices) {
        throw [InvalidOperationException] 'No Modules Exist!'
    } else {
        return @($Choices)
    }
}

#REMOVE THIS -- INSTEAD USE GET-ARGUMENTCOMPLETER FOR TESTABILITY
#https://jamesone111.wordpress.com/2019/09/23/the-classy-way-to-complete-and-validate-powershell-parameters/
class ModuleProjectArgument : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    { 
        $CompletionResults = [List[CompletionResult]]::new()
        @(Get-ModuleProjectArgumentCompleter $WordToComplete) | ForEach-Object {$CompletionResults.Add([CompletionResult]::new($_))}

        return $CompletionResults
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

#REMOVE THIS -- INSTEAD USE GET-ARGUMENTCOMPLETER FOR TESTABILITY
class ApprovedVerbsArgument : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    { 
        $CompletionResults = [List[CompletionResult]]::new()
        Get-ApprovedVerbsArgumentCompleter $WordToComplete | ForEach-Object {$CompletionResults.Add([CompletionResult]::new($_))}
        
        return $CompletionResults
    }
}

function Get-CommandFromModuleArgumentCompleter {
    param (
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )

    if($FakeBoundParameters.Contains('ModuleProject')) {
        $ModuleProject = $FakeBoundParameters['ModuleProject']
        $Choices = @()
        $ModuleProjects = Get-ValidModuleProjectNames 
        if ($ModuleProject -in $ModuleProjects) {
            [Array]$Functions = Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject | Where-Object {$_ -like "$WordToComplete*"}
            if ($Functions) { $Choices += $Functions }

            [Array]$Aliases = Get-ModuleProjectAliasNames -ModuleProject $ModuleProject | Where-Object {$_ -like "$WordToComplete*"}
            if ($Aliases) { $Choices += $Aliases }

            if (!$Choices) {
                throw [InvalidOperationException] 'No Matching Commands Exist in Module!'
            } else {
                return @($Choices)
            }
        } else {
            throw [InvalidOperationException] 'No Modules Exist!'
        }
    }  
}

#REMOVE THIS -- INSTEAD USE GET-ARGUMENTCOMPLETER FOR TESTABILITY
class CommandFromModuleArgument : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    { 
        $CompletionResults = [List[CompletionResult]]::new()
        if($FakeBoundParameters.Contains('ModuleProject')) {
            Get-CommandFromModuleArgumentCompleter $FakeBoundParameters['ModuleProject'] $WordToComplete | ForEach-Object {$CompletionResults.Add([CompletionResult]::new($_))}
        }

        return $CompletionResults
    }
}