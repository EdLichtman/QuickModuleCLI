# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-ModuleFunction {
    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandDoesNotExist $_})]
        [string] $FunctionName,

        [Parameter(Mandatory=$false)]
        [string] 
        $FunctionText,

        [Parameter()]
        [Switch]$Force
    )
    if (!$Force) {
        ValidateCommandStartsWithApprovedVerb -Command $FunctionName
    }
    New-ModuleProjectFunction -ModuleProject $ModuleProject -CommandName $FunctionName -Text (SemicolonCreatesLineBreakTransformation $FunctionText)

    if ([String]::IsNullOrWhiteSpace($FunctionText)) {
        Edit-ModuleCommand -ModuleProject $ModuleProject -CommandName $FunctionName
    }

    Update-ModuleProject -ModuleProject $ModuleProject
    Import-Module $BaseModuleName -Force -Global

}
Register-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName FunctionName -ScriptBlock (Get-Command ApprovedVerbsArgumentCompleter).ScriptBlock