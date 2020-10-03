<#
.SYNOPSIS

Adds a User-Defined function to the Quick-Package Module.

.DESCRIPTION

Adds a User-Defined function to the Quick-Package Module to later be used globally. 
Once the function is part of the Quick-Package Module, it will be imported every time 
you open a new PowerShell Session.

.NOTES

This function is intended to create a short function spanning only a few Semi-Colon delimited lines. 
Therefore, the function does not support multi-line strings. It is highly recommended that if your function 
is to be more complex, consider using "Add-QuickFunctionWithEditor" instead.

.INPUTS

None. You cannot pipe objects to Add-QuickFunction.

.OUTPUTS

None. Add-QuickFunction creates a new function that you can later use.

.EXAMPLE

PS> Add-QuickFunction
Please enter the name of the new function: Write-Echo
Please enter the Function: Write-Output (Read-Host "Are you my echo?")

.EXAMPLE

PS> Add-QuickFunction Write-Echo 'Please enter the Function: Write-Output (Read-Host "Are you my echo?")'

.LINK

https://github.com/EdLichtman/Quick-Package

#>
function global:Add-QuickFunction {
    param(
        [string]
        #Specifies the name of the new function
        $functionName,
        [string]
        #Specifies the content that should go in the function. Line breaks will automatically 
        #be added after semi semicolons. If the -Raw flag is added after, 
        #it will specify the content that should go in the newly-created file.
        $functionText,
        [Switch]
        #Specifies that the file text should contain the -functionText value as is, with no function shell 
        #and no additional line breaks.
        $Raw
    )
    
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1'"
    Invoke-Expression ". '$QuickReservedHelpersRoot\New-FileWithContent.ps1'"
    if (Exit-AfterImport) {
        Test-ImportCompleted
        return;
    }
    # if (Test-Integration) {
    #     Invoke-Expression (Get-IntegrationTestEnvironment)
    # }

    $functionName = Test-QuickFunctionVariable $PSBoundParameters 'functionName' 'Please enter the name of the new function'
    $functionText = Test-QuickFunctionVariable $PSBoundParameters 'functionText' 'Please enter the Function'
    
    $ApprovedVerbs = [System.Collections.Generic.HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;
    $chosenVerb = $functionName.Split('-')[0]

    if (!$ApprovedVerbs.Contains($chosenVerb)) {
        throw [System.ArgumentException] "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'." 
        return;
    }

    $newCode = $functionText
    $newFunctionText = ""
    if (!$Raw) {
        $NumberOfSingleQuotes = 0
        $NumberOfDoubleQuotes = 0
        foreach($character in [char[]]$functionText) {
            if ($character -eq "'") {
                $NumberOfSingleQuotes++
            }
            if ($character -eq '"') {
                $NumberOfDoubleQuotes++
            }
            if (($NumberOfDoubleQuotes % 2 -eq 0) -and ($NumberOfSingleQuotes % 2 -eq 0) -and ($character -eq ';')) {
                $newFunctionText += ";`r`n    "
            } else {
                $newFunctionText += $character
            }
        }
        $newCode = 
@"
function global:$FunctionName {
    $newFunctionText
}

"@
    }

    New-FileWithContent -filePath "$QuickFunctionsRoot\$FunctionName.ps1" -fileText $newCode
    Invoke-Expression $newCode

    #Export Member to Module
    $psd1Location = "$(Split-Path (Get-Module Quick-Package).Path)\Quick-Package.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)
    $NewFunctionsToExport = New-Object System.Collections.ArrayList($null)
    $NewFunctionsToExport.AddRange($psd1.FunctionsToExport)
    $NewFunctionsToExport.Add($FunctionName) | Out-Null
    $psd1.FunctionsToExport = $NewFunctionsToExport;
    Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
@"

"@
}