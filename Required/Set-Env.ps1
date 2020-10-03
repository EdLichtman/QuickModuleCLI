<#
.SYNOPSIS

Adds a system or user variable.

.DESCRIPTION

This function is a wrapper around the [Environment]::SetEnvironmentVariable function. It first checks to see if the environment 
variable exists, then asks if you wish to overwrite it.

.NOTES

[EnvironmentVariableTarget] can be interpreted from the strings "User" or "Machine"

.INPUTS

None. You cannot pipe objects to Set-Env

.OUTPUTS

None. Set-Env creates environment configuration that you can later use.

.EXAMPLE

PS C:\> Set-Env
Please enter Environment Variable Name: Desktop
Please enter Environment Variable Value: C:\Users\User\Path-To-Desktop
PS C:\>
...
PS C:\>Set-Location $env:Desktop
PS C:\Users\User\Path-To-Desktop>

.EXAMPLE

PS C:\> Set-Env -variable Desktop -value C:\Users\User\Path-To-Desktop
PS C:\>
...
PS C:\>Set-Location $env:Desktop
PS C:\Users\User\Path-To-Desktop>

.EXAMPLE

PS C:\> Set-Env -variable Desktop -value C:\Users\User\Path-To-Desktop

A value already exists for the User variable 'Desktop'
Would you like to overwrite?
[Y] Yes  [N] No  [?] Help (default is "N"):Y
PS C:\>
...
PS C:\>Set-Location $env:Desktop
PS C:\Users\User\Path-To-Desktop>

.EXAMPLE

PS C:\> Set-Env -variable MyApplication -value "C:\Program Files\Path-To-My-Application" -environmentVariableTarget "Machine"
PS C:\>
...
PS C:\>Set-Location $env:MyApplication
PS C:\Program Files\Path-To-My-Application>

.LINK

https://github.com/EdLichtman/Quick-Package

#>
function global:Set-Env {
    param (
        [String] $variable,
        [String] $value,
        [EnvironmentVariableTarget] $environmentVariableTarget = [EnvironmentVariableTarget]::User
    )

    if (!$PSBoundParameters.ContainsKey('variable')) {
        $variable = Read-Host 'Please enter Environment Variable Name'
    }

    $existingVariable = [System.Environment]::GetEnvironmentVariable($variable,$environmentVariableTarget);
    if (![String]::IsNullOrWhiteSpace($existingVariable)) {
        $continue =  $Host.UI.PromptForChoice("A value already exists for the $environmentVariableTarget variable '$variable'", "Would you like to overwrite?", @('&Yes','&No'),1)
        if (!($continue -eq 0)) {
            return;
        }
    }

    if (!$PSBoundParameters.ContainsKey('value')) {
        $value = Read-Host 'Please enter Environment Variable Value'
    }
    [System.Environment]::SetEnvironmentVariable($variable,$value,$environmentVariableTarget)
}