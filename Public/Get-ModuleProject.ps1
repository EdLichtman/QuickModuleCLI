function Get-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [String] $ModuleProject,
        [String] $CommandName,
        [Switch] $Summary
    )
    $LimitToModuleProject = $PSBoundParameters.ContainsKey('ModuleProject');
    $LimitToCommandName = $PSBoundParameters.ContainsKey('CommandName');

    if ($LimitToCommandName -and $Summary) {
        throw 'Cannot display summary if searching for a command!'
    }

    $ModuleProjects = Get-ValidModuleProjects
    foreach($Module in $ModuleProjects) {
        if (!$LimitToModuleProject -or ($LimitToModuleProject -and ($Module.Name -eq $Module))) {
            $Functions = Get-ModuleProjectFunctions -ModuleProject $Module.Name
            $Aliases = Get-ModuleProjectAliases -ModuleProject $Module.Name

            if (!$Summary) {
                if (($Functions.Count -eq 0) -and ($Aliases.Count -eq 0)) {
                    if (!$LimitToCommandName) {
                        $SummaryItem = New-Object System.Object
                        $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                        $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value '[EMPTY]'
                        $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "[EMPTY]"
                        $SummaryItem
                    }
                } else {
                    foreach($Function in $Functions) {
                        if (!$LimitToCommandName -or ($LimitToCommandName -and ($Function.BaseName -eq $CommandName))) {
                            $SummaryItem = New-Object System.Object
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value $Function.BaseName
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "Function"
                            $SummaryItem
                        }
                    }
                    foreach($Alias in $Aliases) {
                        if (!$LimitToCommandName -or ($LimitToCommandName -and ($Alias.BaseName -eq $CommandName))) {
                            $SummaryItem = New-Object System.Object
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value $Alias.BaseName
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "Alias"
                            $SummaryItem
                        }
                    }
                }
            } else {
                $SummaryItem = New-Object System.Object
                $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                $SummaryItem | Add-Member -MemberType NoteProperty -Name "Functions" -Value $Functions.Count
                $SummaryItem | Add-Member -MemberType NoteProperty -Name "Aliases" -Value $Aliases.Count
                $SummaryItem
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName CommandName -ScriptBlock (Get-Command Get-CommandFromOptionalModuleArgumentCompleter).ScriptBlock