<#
.SYNOPSIS

Adds an alias to a QuickModuleCLI nested module.

.DESCRIPTION

Adds an alias to a QuickModuleCLI nested module that can later be auto-loaded based on your $PSModuleAutoLoadingPreference.

.NOTES

Once created, every time you open a new Powershell window the alias will be exported for you to use. Once you attempt to use an alias for the first time
in a powershell session it will auto-import the rest of the module for you.

.INPUTS

None. You cannot pipe objects to Add-ModuleAlias.

.OUTPUTS

None. Add-ModuleAlias creates a new alias that you can later use.

.EXAMPLE

PS> Add-ModuleAlias -NestedModule Default -AliasName echo -AliasMappedFunction 'Write-Output'

.EXAMPLE

PS> Add-ModuleAlias Default echo Write-Output

.LINK

https://github.com/EdLichtman/QuickModuleCLI

#>
function Add-ModuleAlias {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        #Specifies the name of the NestedModule in which this function belongs.
        $NestedModule,
        [Parameter(Mandatory=$true)][string]
        #Specifies the name of the new alias.
        $AliasName,
        [Parameter(Mandatory=$true)][string]
        #Specifies the name of the function to which this alias maps.
        $AliasMappedFunction
    )    
    
    Assert-CanFindCommand -CommandName $AliasMappedFunction
    Assert-CanCreateModuleCommand -CommandName $AliasName -NestedModule $NestedModule

    $newCode = @"
Set-Alias $AliasName $AliasMappedFunction
"@

    New-FileWithContent -filePath "$NestedModulesFolder\$NestedModule\Aliases\$AliasName.ps1" -fileText $newCode

    Update-ModuleProject -NestedModule $NestedModule
    Import-Module $BaseModuleName -Force
}