function Add-QuickFunction {
    param(
        [string]$functionName,
        [string]$functionText,
        [Switch]$addLineBreaks,
        [Switch]$Raw
    )
    
    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1
    . $QuickReservedHelpersRoot\New-FileWithContent.ps1

    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    $functionText = Test-QuickFunctionVariable $PSBoundParameters 'functionText' 'Please enter the Function'
    
    $ApprovedVerbs = [System.Collections.Generic.HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;
    $chosenVerb = $functionName.Split('-')[0]

    if (!$ApprovedVerbs.Contains($chosenVerb)) {
        Write-Output "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'."
        return;
    }

    if ($addLineBreaks) {
        $functionText = $functionText -replace ';', ";    `r"
    }

    $newCode = $functionText
    if (!$Raw) {
    $newCode = 
@"
function global:$FunctionName {
    $FunctionText
}
"@
    }

    New-FileWithContent -filePath "$QuickFunctionsRoot\$FunctionName.ps1" -fileText $newCode
    Invoke-Expression $newCode
}