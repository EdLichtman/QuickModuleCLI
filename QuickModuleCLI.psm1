$helperFunctions = Get-ChildItem "$PSScriptRoot\Root" -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
        . "$PSScriptRoot\Root\$helperFunction"
}