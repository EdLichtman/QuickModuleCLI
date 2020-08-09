function global:Add-QuickUtility {
    param(
        [Switch] $InstallEntireBelt,
        [Switch] $Force
    )
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$QuickReservedHelpersRoot\New-FileWithContent.ps1"
    . "$QuickReservedHelpersRoot\Show-Menu.ps1"
    
    $QuickForceText = if ($Force) { '-force' } else { '' }
    
    $localUtilityBeltPath = "$QuickReservedHelpersRoot\UtilityBelt"
    
    $localUtilityBeltFunctionsPath = "$localUtilityBeltPath\Functions"
    $utilityBeltFunctions = @(Get-ChildItem $localUtilityBeltFunctionsPath -Filter '*.ps1') 
    $localUtilityBeltAliasesPath = "$localUtilityBeltPath\Aliases"
    $utilityBeltAliases = @(Get-ChildItem $localUtilityBeltAliasesPath -Filter '*.ps1')
    
    $UtilityBeltCommands = New-Object System.Collections.ArrayList
    $utilityBeltFunctions | ForEach-Object {
        $obj = [PSCustomObject]@{
            Name = $_ -replace '.ps1', ''
            InstallLocation = "$QuickFunctionsRoot\$_"
            InstallerLocation = "$localUtilityBeltFunctionsPath\$_"
        }
        $UtilityBeltCommands.Add($obj) | Out-Null;
    }
    $utilityBeltAliases | ForEach-Object {
        $obj = [PSCustomObject]@{
            Name = $_ -replace '.ps1', ''
            InstallLocation = "$QuickAliasesRoot\$_"
            InstallerLocation = "$localUtilityBeltAliasesPath\$_"
        }
        $UtilityBeltCommands.Add($obj) | Out-Null;
    }
    
    if ($InstallEntireBelt) {
        foreach($tool in $UtilityBeltCommands) {
            $InstallLocation = $tool.InstallLocation
            $InstallerLocation = $tool.InstallerLocation
            $fileText = "('$QuickUtilityBeltFunctionIdentifier`r' + (Get-Content $InstallerLocation -Raw))"
            Invoke-Expression "New-FileWithContent -FilePath $InstallLocation -FileText $fileText $QuickForceText"
        }
    } else {
        $MenuOptions = @{}
        $MenuOptionMappings = @{}
        $UtilityBeltCommands | ForEach-Object {
            $MenuOptions[$_.Name] = $_.Name
            $MenuOptionMappings[$_.Name] = $_
        }
        $ChosenOption = Show-Menu "Install which tool?" $MenuOptions
    
        $tool = $MenuOptionMappings[$ChosenOption]
        $InstallLocation = $tool.InstallLocation
        $InstallerLocation = $tool.InstallerLocation
        $fileText = "('$QuickUtilityBeltFunctionIdentifier`r' + (Get-Content $InstallerLocation -Raw))"
        Invoke-Expression "New-FileWithContent -FilePath $InstallLocation -FileText $fileText $QuickForceText"
        
    }
    
}