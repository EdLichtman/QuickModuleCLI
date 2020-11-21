. "$PSScriptRoot\Private\Variables.ps1"
if (!(Test-Path "$PSScriptRoot\Modules")) {
        New-Item "$PSScriptRoot\Modules" -ItemType Directory
}

. "$PSScriptRoot\Private\ModuleImports.ps1"

$helperFunctions = Get-ChildItem "$PSScriptRoot\Public" -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
        if (!$helperFunction.BaseName.EndsWith('.Tests')) {
                . "$PSScriptRoot\Public\$helperFunction"
        }
}

foreach($Module in (GetModuleProjectInfo)) {
        Import-Module "$($Module.FullName)\$($Module.Name).psd1" -Force -Global
}

#In theory this will not change the Global Error Action Preference, but will scope this action preference to all of the Module Functions.
$ErrorActionPreference = "Stop"
$IsProduction = $True