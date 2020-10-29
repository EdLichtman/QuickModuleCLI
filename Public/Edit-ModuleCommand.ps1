function Edit-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateModuleProjectExists()]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string]$ModuleProject,
        
        [Parameter(Mandatory=$true)]
        [string]$CommandName
        
    )
    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName

    $Function = Get-ModuleProjectFunctionPath -ModuleProject $ModuleProject -CommandName $CommandName
    $Alias = Get-ModuleProjectAliasPath -ModuleProject $ModuleProject -CommandName $CommandName

    if(Test-Path "$Function") {
        . powershell_ise.exe "$Function" 
    }
    elseif(Test-Path "$Alias") {
        . powershell_ise.exe "$Alias"
    } 

    Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

    Import-Module $BaseModuleName -Force
}