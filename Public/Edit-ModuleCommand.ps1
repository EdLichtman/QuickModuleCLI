function Edit-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        #[ValidateModuleProjectExists()]
        #[ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string]$ModuleProject,
        
        [Parameter(Mandatory=$true)]
        [string]$CommandName
        
    )
    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName

    $CommandType, $Command = Get-ModuleProjectCommand -ModuleProject $ModuleProject -CommandName $CommandName
    Open-PowershellEditor -Path $Command.FullName
    Wait-ForKeyPress

    Import-Module $BaseModuleName -Force
}