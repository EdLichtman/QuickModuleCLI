. "$PSScriptRoot\Root\Reserved\PrivateFunctions.ps1"
$helperFunctions = Get-ChildItem "$PSScriptRoot\Root" -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
        . "$PSScriptRoot\Root\$helperFunction"
        Register-SubModuleArgumentCompleter -CommandName $helperFunction.BaseName
}
if (!(Test-Path "$PSScriptRoot\Modules")) {
        New-Item "$PSScriptRoot\Modules" -ItemType Directory
}

#In theory this will not change the Global Error Action Preference, but will scope this action preference to all of the Module Functions.
$ErrorActionPreference = "Stop"