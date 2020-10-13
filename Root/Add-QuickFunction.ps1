<#
.SYNOPSIS

Adds a function to a QuickModuleCLI nested module.

.DESCRIPTION

Adds a function to a QuickModuleCLI nested module that can later be auto-loaded based on your $PSModuleAutoLoadingPreference.

.NOTES

Once created, every time you open a new Powershell window the function will be exported for you to use. Once you attempt to use a function for the first time
in a powershell session it will auto-import the rest of the module for you.

If you use this function with the $functionText parameter, then your function will be automatically formatted with line breaks, wherever you had included semi-colons (;).
Additionally, if you do not include the $functionText parameter, then this function will open your Powershell ISE for you to modify the function there.

.INPUTS

None. You cannot pipe objects to Add-QuickFunction.

.OUTPUTS

None. Add-QuickFunction creates a new function that you can later use.

.EXAMPLE

PS> Add-QuickFunction -NestedModule Default -functionName Write-Echo -functionText 'Write-Output (Read-Host "Are you my echo?")'

.EXAMPLE

PS> Add-QuickFunction Default Write-Echo 'Please enter the Function: Write-Output (Read-Host "Are you my echo?")'

.EXAMPLE

PS> Add-QuickFunction Default Write-Echo 
[PS ISE opens...]
Press any key when you are finished editing...

.LINK

https://github.com/EdLichtman/QuickModuleCLI

#>
function Add-QuickFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        #Specifies the name of the NestedModule in which this function belongs.
        $NestedModule,
        [Parameter(Mandatory=$true)]
        [string]
        #Specifies the name of the new function
        $functionName,
        [string]
        #Specifies the content that should go in the function. Line breaks will automatically 
        #be added after semi semicolons.
        $functionText
    )
    
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\New-FileWithContent.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Update-QuickModuleCLI.ps1'"
    Invoke-Expression ". '$PrivateFunctionsFolder\Test-QuickCommandExists.ps1'"
    Invoke-Expression ". '$FunctionsFolder\New-QuickModule.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"


    if (Exit-AfterImport) {
        Test-ImportCompleted
        return;
    }
    
    $ApprovedVerbs = [System.Collections.Generic.HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;
    $chosenVerb = $functionName.Split('-')[0]

    if (!$ApprovedVerbs.Contains($chosenVerb)) {
        throw [System.ArgumentException] "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'." 
        return;
    }

    Test-QuickCommandExists $functionName
    if (!(Test-Path $NestedModulesFolder\$NestedModule)) {
        if ((Get-Module -ListAvailable $NestedModule)) {
            throw [System.ArgumentException] "A module is already available by the name '$NestedModule'. This module does not support clobber and Prefixes."
        }
        $Continue = $Host.UI.PromptForChoice("No Module by the name '$NestedModule' exists.", "Would you like to create a new one?", @('&Yes','&No'), 0)
        if ($Continue -eq 0) {
            New-QuickModule -NestedModule $NestedModule;
        } else {
            return;
        }
    }

    $newFunctionText = ""

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
        $newCode = @"
function $FunctionName {
    $newFunctionText
}
"@


    New-FileWithContent -filePath "$NestedModulesFolder\$NestedModule\Functions\$FunctionName.ps1" -fileText $newCode
    if ([String]::IsNullOrWhiteSpace($newFunctionText)) {
        powershell_ise.exe "$NestedModulesFolder\$NestedModule\Functions\$FunctionName.ps1"
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    Update-QuickModule -NestedModule $NestedModule
    Update-QuickModuleCLI
    Import-Module $BaseModuleName -Force
}