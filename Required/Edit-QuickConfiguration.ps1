<#
.SYNOPSIS

Edits the User-Defined configuration in the Quick-Package Module.

.DESCRIPTION

Edits the User-Defined configuration in the Quick-Package Module to later be used globally. 
The configuration is part of the Quick-Package Module, it will be imported every time 
you open a new PowerShell Session. 

.NOTES

A configuration may be an override to an existing function, or it may be the addition of a profile variable.
Because configuration is not easy to name, and therefore separate into files, it his highly recommended you
keep your configuration organized in case you need to remove or alter it. A good example of a modification 
to the configuration is overwriting the prompt to add the Date/Time to it.

.INPUTS

None. You cannot pipe objects to Edit-QuickConfiguration.

.OUTPUTS

None. Edit-QuickConfiguration creates a new configuration that you can later use.

.EXAMPLE

PS> Edit-QuickConfiguration

.LINK

https://github.com/EdLichtman/Quick-Package

#>
function global:Edit-QuickConfiguration {
    
    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"

    if (Exit-AfterImport) {
        Test-ImportCompleted
        return;
    }

    if (!(Test-Path $QuickConfigurationsFile)) {
        New-Item -ItemType File -Force -Path $QuickConfigurationsFile | Out-null
    }

    Invoke-Expression ". powershell_ise.exe '$QuickConfigurationsFile'"
}