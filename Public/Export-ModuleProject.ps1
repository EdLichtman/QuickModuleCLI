function Export-ModuleProject {
    [CmdletBinding(
        SupportsShouldProcess
        )]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExportDestinationIsValid $_})]
        [string] $Path,
        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject,
        [Parameter()]
        [switch]
        $Force
    )  

    if (!$Path.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $Path += [System.IO.Path]::DirectorySeparatorChar
    }
    
    $ModuleProjects = Get-ValidModuleProjects 
    if ($ModuleProject) {
        $ModuleProjects = $ModuleProjects | Where-Object { $_.Name -eq $ModuleProject }
    }

    foreach($ModuleProjectFolder in $ModuleProjects) {
        if ($Force) {
            $ExportedModuleLocation = "$Path\$($ModuleProjectFolder.Name)"
            if (Test-Path $ExportedModuleLocation) {
                Remove-Item -Path $ExportedModuleLocation -Recurse -Force
            }  
        }
    
        Copy-Item -Path $ModuleProjectFolder.FullName -Destination $Path -Recurse -Force:$Force;
    }
}

Register-ArgumentCompleter -CommandName Export-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock