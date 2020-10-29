# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-ModuleFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter([ModuleProjectArgument])]
        [string] $NestedModule,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateParameterStartsWithApprovedVerb()]
        [string] $FunctionName,

        [SemicolonCreatesLineBreakTransformation()]
        [string] 
        $FunctionText
    )

    
       

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