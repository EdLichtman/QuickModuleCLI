function Assert-ModuleProjectExists {
    if ($_ -in (Get-ModuleProjectChoices)) {
        $True
    } else {
        throw [ArgumentException] "Parameter must be one of the following choices: $(Get-ModuleProjectChoices)"
    }
}

function Assert-ModuleProjectDoesNotExist {
    try {
        $Choices = (Get-ModuleProjectChoices)
    } catch [System.Management.Automation.ItemNotFoundException] {
        if ($_.Exception.Message -like 'No viable Modules.*') {
            return $True 
        }
    }

    if ($_ -in $Choices) {
        throw [ArgumentException] "Parameter must not be one of the following choices, as they already exist: $(Get-ModuleProjectChoices)"
    } else {
        $True
    }
}

function Assert-ModuleCommandExists {
    $NestedModules = Get-NestedModules

    if (Test-Path (Get-NestedModuleLocation -NestedModule $NestedModule)) {
        foreach($NestedModule in $NestedModules) {
            $Functions = Get-ModuleFunctionLocations -NestedModule $NestedModule
            $Aliases = Get-ModuleAliasesLocations -NestedModule $NestedModule
            foreach($Function in $Functions) {
                if ($Function.BaseName -eq $CommandName) {
                    return $True
                }
            }
            foreach($Alias in $Aliases) {
                if ($Alias.BaseName -eq $CommandName) {
                    return $True
                }
            }
        } 
    }

    throw "'$CommandName' does not as a function in any ModuleProject!"
}

function Assert-ModuleCommandDoesNotExist {
    $NestedModules = Get-NestedModules

    if (Test-Path (Get-NestedModuleLocation -NestedModule $NestedModule)) {
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

    return $True
}

function Assert-ParameterStartsWithVerb {
    $ApprovedVerbs = [System.Collections.Generic.HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;
    $chosenVerb = $_.Split('-')[0]

    if (!$ApprovedVerbs.Contains($chosenVerb)) {
        throw [System.ArgumentException] "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'." 
    }

    return $True
}