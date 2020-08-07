param(
    [Switch] $InstallEntireBelt,
    [Switch] $Force
)

$localHelpersPath = ".\Required"
. $localHelpersPath\Get-QuickEnvironment.ps1
. $localHelpersPath\New-FileWithContent.ps1

. .\Installer\Show-Menu.ps1

$QuickForceText = if ($Force) { '-force' } else { '' }

$localUtilityBeltPath = ".\UtilityBelt"


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
        Invoke-Expression "New-FileWithContent -FilePath $InstallLocation -FileText (Get-Content $InstallerLocation -Raw) $QuickForceText"
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
    Invoke-Expression "New-FileWithContent -FilePath $InstallLocation -FileText (Get-Content $InstallerLocation -Raw) $QuickForceText"
    
}
