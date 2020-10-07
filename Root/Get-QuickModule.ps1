function Get-QuickModule {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [String] 
        
        $NestedModule,
        [String]
        $CommandName,
        [Switch]
        $Summary
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"

    $Modules = New-Object System.Collections.ArrayList;

    $LimitToNestedModule = $PSBoundParameters.ContainsKey('NestedModule');
    $LimitToCommandName = $PSBoundParameters.ContainsKey('CommandName');

    if ($LimitToCommandName -and $Summary) {
        throw 'Cannot display summary if searching for a command!'
    }

    $NestedModules = Get-ChildItem $NestedModulesFolder
    foreach($Module in $NestedModules) {
        if (!$LimitToNestedModule -or ($LimitToNestedModule -and ($Module.Name -eq $NestedModule))) {
            $ModulePath = "$NestedModulesFolder\$($Module.Name)"
            $FunctionsPath = "$ModulePath\Functions"
            $AliasesPath = "$ModulePath\Aliases"
            $Functions = Get-Item $FunctionsPath
            $Aliases = Get-Item $AliasesPath

            if (!$Summary) {
                if (($Functions.GetFiles().Count -eq 0) -and ($Aliases.GetFiles().Count -eq 0)) {
                    if (!$LimitToCommandName) {
                        $SummaryItem = New-Object System.Object
                        $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                        $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value '[EMPTY]'
                        $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "[EMPTY]"
                        $Modules.Add($SummaryItem) | Out-Null
                    }
                } else {
                    foreach($Function in Get-ChildItem $Functions) {
                        if (!$LimitToCommandName -or ($LimitToCommandName -and ($Function.BaseName -eq $CommandName))) {
                            $SummaryItem = New-Object System.Object
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value $Function.BaseName
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "Function"
                            $Modules.Add($SummaryItem) | Out-Null
                        }
                    }
                    foreach($Alias in Get-ChildItem $Aliases) {
                        if (!$LimitToCommandName -or ($LimitToCommandName -and ($Alias.BaseName -eq $CommandName))) {
                            $SummaryItem = New-Object System.Object
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value $Alias.BaseName
                            $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "Alias"
                            $Modules.Add($SummaryItem) | Out-Null
                        }
                    }
                }
            } else {
                $SummaryItem = New-Object System.Object
                    $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
                    $SummaryItem | Add-Member -MemberType NoteProperty -Name "Functions" -Value $Functions.GetFiles().Count
                    $SummaryItem | Add-Member -MemberType NoteProperty -Name "Aliases" -Value $Aliases.GetFiles().Count
                    $Modules.Add($SummaryItem) | Out-Null
            }
        }
    }
    
    Write-Output $Modules
}