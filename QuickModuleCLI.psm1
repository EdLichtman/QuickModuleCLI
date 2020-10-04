. "$PSScriptRoot\Root\Reserved\Get-QuickEnvironment.ps1"

$helperFunctions = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
    $helperName = $helperFunction.BaseName;
    if (!$helperName.EndsWith('.Tests')) {
        . $QuickHelpersRoot\$helperFunction
    }
}