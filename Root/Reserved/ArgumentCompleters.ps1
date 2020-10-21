function Get-ModuleProjectChoices {
    $Choices = (Get-NestedModules | 
        Where-Object {
            $files = Get-ChildItem $_.FullName | Select-Object -Property Name
            $ModuleName = $_.BaseName;
            return $files -and ($files -match "$ModuleName.psd1" -and $files -match "$ModuleName.psm1")
        } | 
        ForEach-Object {
            "$($_.Name)"
        });

    if (!$Choices) {
        throw [System.Management.Automation.ItemNotFoundException]'No viable Modules. Please create one with New-ModuleProject!'
    }
    return $Choices
}