using namespace System.Collections.Generic
$_ModuleProjects,
$_ModuleProjectInfos, 
$_ModuleProjectCommands, 
$_ModuleProjectCommandFiles, 
$_ModuleProjectCommandTypes, 
$_ModuleProjectCommandDefinitions = (GetCommandEnvironmentVariables)

$_Commands = [HashSet[String]]::new()
if ($_ModuleProjectsCommands.Keys) {
    $_ModuleProjectsCommands.Keys | ForEach-Object { $_Commands.Add($_) | Out-Null }
}
$_ModuleProjectNames = [HashSet[String]]::new()
if ($_ModuleProjects.Name) {
    $_ModuleProjects.Name | ForEach-Object { $_ModuleProjectNames.Add($_) | Out-Null }
}

$_ApprovedVerbs = (Get-ApprovedVerbs)