function Edit-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string]$ModuleProject,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandExists $_})]
        [string]$CommandName
        
    )
    if ($ModuleProject) {
        ValidateCommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName
    }

    $File = GetFileForCommand -CommandName $CommandName
    Open-PowershellEditor -Path $File.FullName
    Wait-ForKeyPress

    Import-Module $BaseModuleName -Force -Global
}

Register-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command CommandFromOptionalModuleArgumentCompleter).ScriptBlock