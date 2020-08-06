param(
    [Switch] $InstallUtilityBelt,
    [Switch] $Force
)

$localHelpersPath = ".\Required"
. $localHelpersPath\Get-UDPowershellEnvironment.ps1

New-FolderIfNotExists $PowershellUserProfileRoot
New-FolderIfNotExists $functionsRoot
New-FolderIfNotExists $aliasesRoot
New-FolderIfNotExists $HelpersRoot

$forceText = if ($Force) { '-force' } else { '' }

$helpers = @(Get-ChildItem $localHelpersPath -Filter '*.ps1')
foreach($helper in $helpers) {
    if (!(Test-Path $helpersRoot\$helper) -or $Force){
        Invoke-Expression "New-FileWithContent -FilePath $helpersRoot\$helper -FileText (Get-Content $localHelpersPath\$helper -Raw) $forceText"
    } 
}

if ($InstallUtilityBelt) {
    $localUtilityBeltPath = ".\UtilityBelt"
    $localUtilityBeltFunctionsPath = "$localUtilityBeltPath\Functions"
    $utilityBeltFunctions = @(Get-ChildItem $localUtilityBeltFunctionsPath -Filter '*.ps1')
    foreach($function in $utilityBeltFunctions) {
        Invoke-Expression "New-FileWithContent -FilePath $functionsRoot\$function -FileText (Get-Content $localUtilityBeltFunctionsPath\$function -Raw) $forceText"
    }

    $localUtilityBeltAliasesPath = "$localUtilityBeltPath\Aliases"
    $utilityBeltAliases = @(Get-ChildItem $localUtilityBeltAliasesPath -Filter '*.ps1')
    foreach($alias in $utilityBeltAliases) {
        Invoke-Expression "New-FileWithContent -FilePath $aliasesRoot\$alias -FileText (Get-Content $localUtilityBeltAliasesPath\$alias -Raw) $forceText"
    }
}


if ($Force -and (Test-Path $PowershellProfilePath)) {
    Remove-Item $PowershellProfilePath
}
if (!(Test-Path $PowershellProfilePath)) {
    New-FileWithContent $PowershellProfilePath ''
}
Add-Content $PowershellProfilePath `
@"
Import-Module UDFunction-Builder
"@

if ($Force -and (Test-Path $PowershellModulePath)) {
    Remove-Item $PowershellModulePath
}
if (!(Test-Path $PowershellModulePath)) {
    New-FileWithContent $PowershellModulePath  `
@"
$('$helperFunctions') = Get-ChildItem $helpersRoot -Filter "*.ps1"
foreach($('$helperFunction') in $('$helperFunctions')) {
    . $helpersRoot\$('$helperFunction')
}

$('$functions') = Get-ChildItem $functionsRoot -Filter "*.ps1"
foreach($('$function') in $('$functions')) {
    . $functionsRoot\$('$function')
}
$('$aliases') = Get-ChildItem $aliasesRoot -Filter "*.ps1"
foreach($('$alias') in $('$aliases')) {
    . $aliasesRoot\$('$alias')
}
"@

}
