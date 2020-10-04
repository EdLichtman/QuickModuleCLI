function global:Add-QuickAlias {
    param(
        [Parameter(Mandatory=$true)][string]$QuickModule,
        [Parameter(Mandatory=$true)][string]$AliasName,
        [Parameter(Mandatory=$true)][string]$AliasText,
        [Switch]$Raw
    )
    
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$QuickReservedHelpersRoot\Test-CommandExists.ps1"
    . "$QuickReservedHelpersRoot\New-FileWithContent.ps1"
    Invoke-Expression ". '$QuickHelpersRoot\New-QuickModule.ps1'"
    Invoke-Expression ". '$QuickHelpersRoot\Update-QuickModule.ps1'"
    
    if (!(Test-Path $QuickPackageModuleContainerPath\$QuickModule)) {
        $Continue = $Host.UI.PromptForChoice("No Module by the name '$QuickModule' exists.", "Would you like to create a new one?", @('&Yes','&No'), 0)
        if ($Continue -eq 0) {
            New-QuickModule $QuickModule;
        } else {
            return;
        }
    }

    if (Test-CommandExists $aliasName) {
        Write-Output "That alias already exists as a command. $QuickPackageModuleName does not support Clobber."
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
Set-Alias $AliasName $AliasText -Scope Global
"@
    }

    New-FileWithContent -filePath "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1" -fileText $newCode
    if ([String]::IsNullOrWhiteSpace($newFunctionText)) {
        powershell_ise.exe "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1"
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    Update-QuickModule -QuickModule $QuickModule
    Reset-QuickCommand -QuickModule $QuickModule -commandName $AliasName
}