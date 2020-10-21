# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-ModuleFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $NestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Assert-ParameterStartsWithVerb)})]
        [string] $FunctionName,

        [string] $FunctionText
    )

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

    Update-ModuleProject -NestedModule $NestedModule
    Update-ModuleProjectCLI
    Import-Module $BaseModuleName -Force
}