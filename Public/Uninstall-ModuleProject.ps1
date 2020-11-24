function Uninstall-ModuleProject {
    param(
        [Switch] $Force
    )

    if (!$Force) {
        $ExportModules = Confirm-Choice -Title 'Uninstalling Module...' -Prompt "Uninstalling Module '$BaseModuleName'. Uninstalling will get rid of any ModuleProjects you've written. Would you like to export them?" -DefaultsToYes
        if ($ExportModules) {
            $DownloadsFolder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
            $ExportPath = "$DownloadsFolder\$BaseModuleName\Exported\"
            Write-Output "Exporting ModuleProjects to $ExportPath"
            
            Export-ModuleProject -Path $ExportPath -Force
        }
    }

    Uninstall-Module $BaseModuleName
}