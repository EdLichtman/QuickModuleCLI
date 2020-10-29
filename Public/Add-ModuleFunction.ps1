# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-ModuleFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter([ModuleProjectArgument])]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateParameterStartsWithApprovedVerb()]
        [string] $FunctionName,

        [SemicolonCreatesLineBreakTransformation()]
        [string] 
        $FunctionText
    )

    New-ModuleProjectFunction -ModuleProject $ModuleProject -CommandName $FunctionName -Text $FunctionText
    $FunctionLocation = Get-ModuleProjectFunctionPath -ModuleProject $ModuleProject -CommandName $FunctionName
    if ([String]::IsNullOrWhiteSpace($newFunctionText)) {
        powershell_ise.exe $FunctionLocation
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    #Update-ModuleProject -NestedModule $NestedModule
    #Update-ModuleProjectCLI
    #Import-Module $BaseModuleName -Force
}