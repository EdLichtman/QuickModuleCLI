<#
.SYNOPSIS

Adds an alias to a QuickModuleCLI nested module.

.DESCRIPTION

Adds an alias to a QuickModuleCLI nested module that can later be auto-loaded based on your $PSModuleAutoLoadingPreference.

.NOTES

Once created, every time you open a new Powershell window the alias will be exported for you to use. Once you attempt to use an alias for the first time
in a powershell session it will auto-import the rest of the module for you.

.INPUTS

None. You cannot pipe objects to Add-QuickAlias.

.OUTPUTS

None. Add-QuickAlias creates a new alias that you can later use.

.EXAMPLE

PS> Add-QuickAlias -NestedModule Default -AliasName echo -AliasMappedFunction 'Write-Output'

.EXAMPLE

PS> Add-QuickAlias Default echo Write-Output

.LINK

https://github.com/EdLichtman/QuickModuleCLI

#>
function Add-QuickAlias {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]
        #Specifies the name of the NestedModule in which this function belongs.
        $NestedModule,
        [Parameter(Mandatory=$true)][string]
        #Specifies the name of the new alias.
        $AliasName,
        [Parameter(Mandatory=$true)][string]
        #Specifies the name of the function to which this alias maps.
        $AliasMappedFunction
    )    
    
    Invoke-Expression ". '$PSScriptRoot\Reserved\PrivateFunctions.ps1'"
    Invoke-Expression ". '$FunctionsFolder\Update-QuickModule.ps1'"
    
    Assert-CanFindCommand -CommandName $AliasMappedFunction
    Assert-CanCreateQuickCommand -CommandName $AliasName
    Assert-TryCreateModule -NestedModule $NestedModule



    $newCode = @"
Set-Alias $AliasName $AliasMappedFunction
"@

    New-FileWithContent -filePath "$NestedModulesFolder\$NestedModule\Aliases\$AliasName.ps1" -fileText $newCode

    Update-QuickModule -NestedModule $NestedModule
    Import-Module $BaseModuleName -Force
}