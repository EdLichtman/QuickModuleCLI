. "$PSScriptRoot\Private\Variables.ps1"
. "$PSScriptRoot\Private\Environment.ps1"
. "$PSScriptRoot\Private\ArgumentCompleters.ps1"
. "$PSScriptRoot\Private\ArgumentTranformations.ps1"
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

#In theory this will not change the Global Error Action Preference, but will scope this action preference to all of the Module Functions.
$ErrorActionPreference = "Stop"