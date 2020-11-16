function Edit-ModuleCommand {
    [CmdletBinding()]
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
    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName

    $CommandType, $Command = Get-ModuleProjectCommand -ModuleProject $ModuleProject -CommandName $CommandName
    Open-PowershellEditor -Path $Command.FullName
    Wait-ForKeyPress

    #Import-Module $BaseModuleName -Force
}

Register-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command Get-CommandFromModuleArgumentCompleter).ScriptBlock