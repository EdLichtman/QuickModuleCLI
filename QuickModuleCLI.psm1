$helperFunctions = Get-ChildItem "$PSScriptRoot\Root" -Filter "*.ps1"
foreach($helperFunction in $helperFunctions) {
    $helperName = $helperFunction.BaseName;
    if (!$helperName.EndsWith('.Tests')) {
        . $QuickHelpersRoot\$helperFunction
    }
}