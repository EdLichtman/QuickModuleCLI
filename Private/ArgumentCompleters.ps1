using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation 
using namespace System.Management.Automation.Language


function Get-ModuleProjectChoices {
    $Choices = Get-ValidModuleProjectNames

    if (!$Choices) {
        throw [System.Management.Automation.ItemNotFoundException]'No viable Modules. Please create one with New-ModuleProject!'
    }
    return $Choices
}

#https://jamesone111.wordpress.com/2019/09/23/the-classy-way-to-complete-and-validate-powershell-parameters/
class ModuleProjectArgument : IArgumentCompleter {
    <# REMEMBER IF TESTING LOCALLY: Dotsource the Get-ValidModuleProjectNames function#>
    static [IEnumerable[String]] GetArguments(
        [string] $WordToComplete
        ) {
            $Choices = [List[String]]::new()
            Get-ValidModuleProjectNames | 
                Where-Object {$_ -like "$WordToComplete*"} | 
                ForEach-Object { $Choices.Add("$_") }
            if (!$Choices) {
                $Choices.Add('[None]')
            }

            return $Choices
    }
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    { 
        $CompletionResults = [List[CompletionResult]]::new()
        [ModuleProjectArgument]::GetArguments($WordToComplete) | ForEach-Object {$CompletionResults.Add([CompletionResult]::new($_))}

        return $CompletionResults
    }
}

class ApprovedVerbsArgument : IArgumentCompleter {
    <# REMEMBER IF TESTING LOCALLY: Dotsource Get-ApprovedVerbs Function#>
    static [IEnumerable[String]] GetArguments(
        [string] $WordToComplete
        ) {
            $Choices = [List[String]]::new()
            Get-ApprovedVerbs | 
                Where-Object {$_ -like "$WordToComplete*"} | 
                ForEach-Object { $Choices.Add("$_-") }
            return $Choices
    }

    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]      $CommandName ,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    )
    { 
        $CompletionResults = [List[CompletionResult]]::new()
        [ApprovedVerbsArgument]::GetArguments($WordToComplete) | ForEach-Object {$CompletionResults.Add([CompletionResult]::new($_))}
        
        return $CompletionResults
    }
}

class CommandFromModuleArgument : IArgumentCompleter {
    <# REMEMBER IF TESTING LOCALLY: Dotsource Get-ApprovedVerbs Function#>
    static [IEnumerable[String]] GetArguments(
        [string] $ModuleProject,
        [string] $WordToComplete
        ) {
            $Choices = [List[String]]::new()
            $ModuleProjects = Get-ValidModuleProjectNames 
            if ($ModuleProjects | Where-Object {$_ -eq $ModuleProject}) {
                Get-ModuleProjectFunctionNames -ModuleProject $ModuleProject | 
                    Where-Object {$_ -like "$WordToComplete*"} | 
                    ForEach-Object { $Choices.Add("$_") }

                Get-ModuleProjectAliasNames -ModuleProject $ModuleProject | 
                    Where-Object {$_ -like "$WordToComplete*"} | 
                    ForEach-Object { $Choices.Add("$_") }
            } else {
                $Choices.Add("[Invalid]")
            }

            if (!$Choices) {
                $Choices.Add('[None]')
            }

            return $Choices
    }

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
            [CommandFromModuleArgument]::GetArguments($FakeBoundParameters['ModuleProject'], $WordToComplete) | ForEach-Object {$CompletionResults.Add([CompletionResult]::new($_))}
        }

        return $CompletionResults
    }
}