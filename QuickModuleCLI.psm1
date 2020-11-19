. "$PSScriptRoot\Private\Variables.ps1"
. "$PSScriptRoot\Private\UI.ps1"
. "$PSScriptRoot\Private\Environment.ps1"
. "$PSScriptRoot\Private\ArgumentCompleters.ps1"
. "$PSScriptRoot\Private\ArgumentTransformations.ps1"
. "$PSScriptRoot\Private\ObjectTransformation.ps1"
. "$PSScriptRoot\..\Private\Validators.Exceptions.ps1"
. "$PSScriptRoot\Private\Validators.ps1"

$helperFunctions = Get-ChildItem "$PSScriptRoot\Public" -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
        if (!$helperFunction.BaseName.EndsWith('.Tests')) {
                . "$PSScriptRoot\Public\$helperFunction"
        }
}
if (!(Test-Path "$PSScriptRoot\Modules")) {
        New-Item "$PSScriptRoot\Modules" -ItemType Directory
}

foreach($Module in (Get-ValidModuleProjects)) {
        Import-Module "$($Module.FullName)\$($Module.Name).psd1"
}

#In theory this will not change the Global Error Action Preference, but will scope this action preference to all of the Module Functions.
$ErrorActionPreference = "Stop"