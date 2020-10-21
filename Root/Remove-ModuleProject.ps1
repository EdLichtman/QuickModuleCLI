function Remove-ModuleProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({(Assert-ModuleProjectExists)})]
        [ArgumentCompleter({(Get-ModuleProjectChoices)})]
        [string] $NestedModule
    )
    $ModuleDirectory = Get-NestedModuleLocation -NestedModule $NestedModule
    
    $Continue = $Host.UI.PromptForChoice("Module found at: '$ModuleDirectory'", "Are you sure you would like to delete?", @('&Yes','&No'), 1);
    if ($Continue -eq 0) {
        Remove-Item $ModuleDirectory -Recurse
        Update-ModuleProjectCLI
    }
}