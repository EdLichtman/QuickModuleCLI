$BaseFolder =  "$PSScriptRoot\..\.."
$BaseModuleName = "QuickModuleCLI"
$NestedModulesFolder = "$BaseFolder\Modules"
$FunctionsFolder = "$BaseFolder\Root"
$PrivateFunctionsFolder = "$FunctionsFolder\Reserved"
function Exit-AfterImport {
    #Do Nothing -- Allows us to Mock the function to test that the import headers returned successfully
    return $false;
}

function Test-ImportCompleted {
    #Do Nothing -- Allows us to test whether the function has been called
}