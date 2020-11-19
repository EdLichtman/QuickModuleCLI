function Split-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject
    )

    $ModuleDirectories = Get-EnvironmentModuleDirectories
    $ModulesDirectory = $ModuleDirectories | Where-Object {$_.StartsWith((Split-Path $Profile))}

    if (!(Test-Path "$ModulesDirectory\$NestedModule")) {
        New-Item -Path "$ModulesDirectory\$NestedModule" -ItemType Directory
    }
    Move-Item -Path $NestedModuleDirectory -Destination $ModulesDirectory;
    #Import-Module $BaseModuleName -force
}
Register-ArgumentCompleter -CommandName Split-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command Get-ModuleProjectArgumentCompleter).ScriptBlock