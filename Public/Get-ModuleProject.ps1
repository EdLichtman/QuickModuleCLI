function Get-ModuleProject {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [String] $ModuleProject
    )

    $ModuleProjects = if ($ModuleProject) {
        @($ModuleProject)
    } else {
        (GetModuleProjectInfo).Name
    }

    foreach($Module in $ModuleProjects) {
        $ModuleInfo = if ($ModuleProjects.Count -eq 1) {
            [PSObject][Ordered]@{
                Name = $Module;
                Function = @();
                Alias = @()
            }
        } else {
            [PSCustomObject][Ordered]@{
                Name = $Module;
                Function = @();
                Alias = @()
            }
        }
        

        $Commands = GetCommandsInModuleProject -ModuleProject $Module
        foreach($CommandName in $Commands) {
            if ((GetModuleProjectTypeForCommand -CommandName $CommandName) -eq 'Function') {
                $ModuleInfo.Function += @($CommandName)
            } else {
                $ModuleInfo.Alias += @($CommandName)
            }
        }
        $ModuleInfo #yield return
    }
}

Register-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock