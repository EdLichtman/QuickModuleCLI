# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-ModuleFunction {
    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateModuleCommandDoesNotExist()]
        [ValidateParameterStartsWithApprovedVerb()]
        [string] $FunctionName,

        [Parameter(Mandatory=$false)]
        [SemicolonCreatesLineBreakTransformation()]
        [string] 
        $FunctionText
    )

    New-ModuleProjectFunction -ModuleProject $ModuleProject -CommandName $FunctionName -Text $FunctionText

    if ([String]::IsNullOrWhiteSpace($FunctionText)) {
        Edit-ModuleCommand -ModuleProject $ModuleProject -CommandName $FunctionName
    }

    Import-Module $BaseModuleName -Force
}
Register-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName FunctionName -ScriptBlock (Get-Command Get-ApprovedVerbsArgumentCompleter).ScriptBlock