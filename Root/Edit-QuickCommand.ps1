function Edit-QuickCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$NestedModule,
        [Parameter(Mandatory=$true)]
        [string]$CommandName
        
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"

    $Function = "$NestedModulesFolder\$NestedModule\Functions\$CommandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$CommandName.ps1"

    Assert-CanFindQuickCommand -NestedModule $NestedModule -CommandName $CommandName

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