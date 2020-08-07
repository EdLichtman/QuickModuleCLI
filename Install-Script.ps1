param(
    [Switch] $Force
)

$localHelpersPath = ".\Required"
. $localHelpersPath\Get-QuickEnvironment.ps1

$QuickForceText = if ($Force) { '-force' } else { '' }

New-FolderIfNotExists $QuickPowershellUserProfileRoot
New-FolderIfNotExists $QuickFunctionsRoot
New-FolderIfNotExists $QuickAliasesRoot
New-FolderIfNotExists $QuickHelpersRoot

$helpers = @(Get-ChildItem $localHelpersPath -Filter '*.ps1')
foreach($helper in $helpers) {
    if (!(Test-Path $QuickHelpersRoot\$helper) -or $Force){
        Invoke-Expression "New-FileWithContent -FilePath $QuickHelpersRoot\$helper -FileText (Get-Content $localHelpersPath\$helper -Raw) $QuickForceText"
    } 
}

if ($Force -and (Test-Path $QuickPowershellProfilePath)) {
    Remove-Item $QuickPowershellProfilePath
}
if (!(Test-Path $QuickPowershellProfilePath)) {
    New-FileWithContent $QuickPowershellProfilePath ''
}
if (!(Get-Content $QuickPowershellProfilePath | Select-String 'Import-Module Quick-Package')) {
    Add-Content $QuickPowershellProfilePath `
@"
Import-Module Quick-Package
"@
    
}

if ($Force -and (Test-Path $QuickPowershellModulePath)) {
    Remove-Item $QuickPowershellModulePath
}
if (!(Test-Path $QuickPowershellModulePath)) {
    New-FileWithContent $QuickPowershellModulePath  `
@"
$('$helperFunctions') = Get-ChildItem $QuickHelpersRoot -Filter "*.ps1"
foreach($('$helperFunction') in $('$helperFunctions')) {
    . $QuickHelpersRoot\$('$helperFunction')
}

$('$functions') = Get-ChildItem $QuickFunctionsRoot -Filter "*.ps1"
foreach($('$function') in $('$functions')) {
    . $QuickFunctionsRoot\$('$function')
}
$('$aliases') = Get-ChildItem $QuickAliasesRoot -Filter "*.ps1"
foreach($('$alias') in $('$aliases')) {
    . $QuickAliasesRoot\$('$alias')
}
"@

}
