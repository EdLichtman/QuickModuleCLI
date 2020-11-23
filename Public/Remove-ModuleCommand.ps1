function Remove-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string]$ModuleProject,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandExists $_})]
        [string]$CommandName
    )
    ValidateCommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName

    Remove-ModuleProjectCommand -ModuleProject $ModuleProject -CommandName $CommandName
    Update-ModuleProject -ModuleProject $ModuleProject
    Import-Module $BaseModuleName -Force -Global
}
Register-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command CommandFromOptionalModuleArgumentCompleter).ScriptBlock