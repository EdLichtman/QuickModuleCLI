function Remove-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
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
    Import-Module $BaseModuleName -Force
}
Register-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command Get-CommandFromModuleArgumentCompleter).ScriptBlock