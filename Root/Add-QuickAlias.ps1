function Add-QuickAlias {
    param(
        [Parameter(Mandatory=$true)][string]$NestedModule,
        [Parameter(Mandatory=$true)][string]$AliasName,
        [Parameter(Mandatory=$true)][string]$AliasText,
        [Switch]$Raw
    )
    
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$PrivateFunctionsFolder\Test-CommandExists.ps1"
    . "$PrivateFunctionsFolder\New-FileWithContent.ps1"
    Invoke-Expression ". '$FunctionsFolder\New-QuickModule.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    
    if (!(Test-Path $NestedModulesFolder\$NestedModule)) {
        $Continue = $Host.UI.PromptForChoice("No Module by the name '$NestedModule' exists.", "Would you like to create a new one?", @('&Yes','&No'), 0)
        if ($Continue -eq 0) {
            New-QuickModule -NestedModule $NestedModule;
        } else {
            return;
        }
    }

    if (Test-CommandExists $aliasName) {
        Write-Output "That alias already exists as a command. $BaseModuleName does not support Clobber."
        return
    }
    if (!(Test-CommandExists $aliasText)) {
        Write-Output "That Function does not exist."
        return
    }

    $newCode = $AliasText
    if (!$Raw){
        $newCode = 
@"
Set-Alias $AliasName $AliasText
"@
    }

    New-FileWithContent -filePath "$NestedModulesFolder\$NestedModule\Aliases\$AliasName.ps1" -fileText $newCode
    if ([String]::IsNullOrWhiteSpace($AliasText)) {
        powershell_ise.exe "$NestedModulesFolder\$NestedModule\Aliases\$AliasName.ps1"
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    Update-QuickModule -NestedModule $NestedModule
    Import-Module $BaseModuleName -Force
}