function Remove-ModuleProject {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject
    )
    
    Remove-ModuleProjectFolder -ModuleProject $ModuleProject

    Import-Module $BaseModuleName -Force -Global #todo test
}
Register-ArgumentCompleter -CommandName Remove-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock