function Edit-ModuleCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string]$NestedModule,
        
        [Parameter(Mandatory=$true)]
        [string]$CommandName
        
    )

    $Function = "$NestedModulesFolder\$NestedModule\Functions\$CommandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$CommandName.ps1"

    Assert-CanFindModuleCommand -NestedModule $NestedModule -CommandName $CommandName

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