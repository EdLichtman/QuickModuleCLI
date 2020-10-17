# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-QuickFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $NestedModule,
        [Parameter(Mandatory=$true)]
        [string] $FunctionName,
        [string] $FunctionText
    )
    
    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"

    $ApprovedVerbs = [System.Collections.Generic.HashSet[String]]::new();
    (Get-Verb | Select-Object -Property Verb) | ForEach-Object {$ApprovedVerbs.Add($_.Verb)} | Out-Null;
    $chosenVerb = $functionName.Split('-')[0]

    if (!$ApprovedVerbs.Contains($chosenVerb)) {
        throw [System.ArgumentException] "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'." 
        return;
    }

    Assert-CanCreateQuickCommand -CommandName $functionName -NestedModule $NestedModule

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