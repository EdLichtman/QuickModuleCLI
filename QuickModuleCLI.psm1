. "$PSScriptRoot\Root\Reserved\Variables.ps1"
. "$PSScriptRoot\Root\Reserved\Environment.ps1"
. "$PSScriptRoot\Root\Reserved\ArgumentCompleters.ps1"
. "$PSScriptRoot\Root\Reserved\Validators.ps1"

$helperFunctions = Get-ChildItem "$PSScriptRoot\Root" -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
        . "$PSScriptRoot\Root\$helperFunction"
}
if (!(Test-Path "$PSScriptRoot\Modules")) {
        New-Item "$PSScriptRoot\Modules" -ItemType Directory
}

#In theory this will not change the Global Error Action Preference, but will scope this action preference to all of the Module Functions.
$ErrorActionPreference = "Stop"