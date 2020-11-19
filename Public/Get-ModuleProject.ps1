# function Get-ModuleProject {
#     [CmdletBinding(PositionalBinding=$false)]
#     param(
#         [ValidateScript({ValidateModuleProjectExists $_})]
#         [String] $ModuleProject,
        
#         [ValidateScript({ValidateModuleCommandExists $_})]
#         [String] $CommandName,
#         [Switch] $Summary
#     )
#     throw 'Needs to be tested and rewritten!'
#     $Modules = New-Object System.Collections.ArrayList;

#     $LimitToModuleProject = $PSBoundParameters.ContainsKey('ModuleProject');
#     $LimitToCommandName = $PSBoundParameters.ContainsKey('CommandName');

#     if ($LimitToCommandName -and $Summary) {
#         throw 'Cannot display summary if searching for a command!'
#     }

#     $NestedModules = Get-ValidModuleProjects
#     foreach($Module in $NestedModules) {
#         if (!$LimitToNestedModule -or ($LimitToNestedModule -and ($Module.Name -eq $NestedModule))) {
#             $Functions = Get-ModuleProjectFunctionsFolder -ModuleProject $Module.Name
#             $Aliases = Get-ModuleProjectAliasesFolder -ModuleProject $Module.Name

#             if (!$Summary) {
#                 if (($Functions.Count -eq 0) -and ($Aliases.Count -eq 0)) {
#                     if (!$LimitToCommandName) {
#                         $SummaryItem = New-Object System.Object
#                         $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
#                         $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value '[EMPTY]'
#                         $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "[EMPTY]"
#                         $Modules.Add($SummaryItem) | Out-Null
#                     }
#                 } else {
#                     foreach($Function in $Functions) {
#                         if (!$LimitToCommandName -or ($LimitToCommandName -and ($Function.BaseName -eq $CommandName))) {
#                             $SummaryItem = New-Object System.Object
#                             $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
#                             $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value $Function.BaseName
#                             $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "Function"
#                             $Modules.Add($SummaryItem) | Out-Null
#                         }
#                     }
#                     foreach($Alias in $Aliases) {
#                         if (!$LimitToCommandName -or ($LimitToCommandName -and ($Alias.BaseName -eq $CommandName))) {
#                             $SummaryItem = New-Object System.Object
#                             $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
#                             $SummaryItem | Add-Member -MemberType NoteProperty -Name "Command" -Value $Alias.BaseName
#                             $SummaryItem | Add-Member -MemberType NoteProperty -Name "Type" -Value "Alias"
#                             $Modules.Add($SummaryItem) | Out-Null
#                         }
#                     }
#                 }
#             } else {
#                 $SummaryItem = New-Object System.Object
#                     $SummaryItem | Add-Member -MemberType NoteProperty -Name "Module" -Value $Module.Name
#                     $SummaryItem | Add-Member -MemberType NoteProperty -Name "Functions" -Value $Functions.Count
#                     $SummaryItem | Add-Member -MemberType NoteProperty -Name "Aliases" -Value $Aliases.Count
#                     $Modules.Add($SummaryItem) | Out-Null
#             }
#         }
#     }
    
#     Write-Output $Modules
# }

# Register-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
# Register-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName CommandName -ScriptBlock (Get-Command Get-CommandFromModuleArgumentCompleter).ScriptBlock