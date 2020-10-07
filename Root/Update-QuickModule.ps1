
function Update-QuickModule {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)][string]
        $NestedModule,

        [String] 
        
        $Author,
        [String]

        $CompanyName,
        [String]

        $Copyright,
        [Version]

        $ModuleVersion,
        [String]

        $Description,
        [String[]]

        $Tags,
        [Uri]

        $ProjectUri,
        [Uri]

        $LicenseUri,
        [Uri]

        $IconUri,
        [String]

        $ReleaseNotes,
        [String]

        $HelpInfoUri
    )

    Invoke-Expression ". '$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1'"
    function Get-CoalescedVariable {
        param(
            [Hashtable] $BoundParameters,
            [String] $Key,
            [Object] $Replacement
        )
        if ($BoundParameters.ContainsKey($Key)) { return $BoundParameters[$Key] }
        return $Replacement
    }
    #Remove Exported Member from Module
    $NestedModuleLocation = "$NestedModulesFolder\$NestedModule"
    if (!(Test-Path $NestedModuleLocation)) {
        Write-Output "No Quick Module found by the name '$NestedModule'"
        return;
    }
    $psd1Location = "$NestedModuleLocation\$NestedModule.psd1"
    $psd1Content = (Get-Content $psd1Location | Out-String)
    $psd1 = (Invoke-Expression $psd1Content)
    
    $FunctionsToExport = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ChildItem "$NestedModuleLocation\Functions";
    if ($Functions) {
        $Functions | ForEach-Object {$FunctionsToExport.Add("$($_.BaseName)")} | Out-Null
    }

    $AliasesToExport = New-Object System.Collections.ArrayList($null)
    $Aliases = Get-ChildItem "$NestedModuleLocation\Aliases";
    if ($Aliases) {
        $Aliases | ForEach-Object {$AliasesToExport.Add("$($_.BaseName)")} | Out-Null
    }

    $ManifestProperties = @{
        Path = $psd1Location
        FunctionsToExport = $FunctionsToExport
        AliasesToExport = $AliasesToExport

        NestedModules = $psd1.NestedModules
        Author = (Get-CoalescedVariable $PSBoundParameters 'Author' $psd1.Author)
        Description = (Get-CoalescedVariable $PSBoundParameters 'Description' $psd1.Description)
        RootModule = $psd1.RootModule
        ModuleVersion = (Get-CoalescedVariable $PSBoundParameters 'ModuleVersion' $psd1.ModuleVersion)
        PowerShellVersion = $psd1.PowerShellVersion
        CompatiblePSEditions = $psd1.CompatiblePSEditions
        CmdletsToExport = $psd1.CmdletsToExport
        Guid = $psd1.Guid
        CompanyName = (Get-CoalescedVariable $PSBoundParameters 'CompanyName' $psd1.CompanyName)
        Copyright = (Get-CoalescedVariable $PSBoundParameters 'Copyright' $psd1.Copyright)
        ClrVersion = $psd1.ClrVersion
        DotNetFrameworkVersion = $psd1.DotNetFrameworkVersion
        PowerShellHostName = $psd1.PowerShellHostName
        PowerShellHostVersion = $psd1.PowerShellHostVersion
        RequiredModules = $psd1.RequiredModules
        TypesToProcess = $psd1.TypesToProcess
        FormatsToProcess = $psd1.FormatsToProcess
        ScriptsToProcess = $psd1.ScriptsToProcess
        RequiredAssemblies = $psd1.RequiredAssemblies
        FileList = $psd1.FileList
        ModuleList = $psd1.ModuleList
        VariablesToExport = $psd1.VariablesToExport
        DscResourcesToExport = $psd1.DscResourcesToExport
        HelpInfoUri = (Get-CoalescedVariable $PSBoundParameters 'HelpInfoUri' $psd1.HelpInfoUri)
    }

    $PrivateData = $psd1.PrivateData.PSData;
    $Tags = (Get-CoalescedVariable $PSBoundParameters 'Tags' $PrivateData.Tags)
    $IconUri = (Get-CoalescedVariable $PSBoundParameters 'IconUri' $PrivateData.IconUri)
    $ReleaseNotes = (Get-CoalescedVariable $PSBoundParameters 'ReleaseNotes' $PrivateData.ReleaseNotes)
    $ProjectUri = (Get-CoalescedVariable $PSBoundParameters 'ProjectUri' $PrivateData.ProjectUri)
    $LicenseUri = (Get-CoalescedVariable $PSBoundParameters 'LicenseUri' $PrivateData.LicenseUri)

    if ($Tags) { $ManifestProperties.Add('Tags', $Tags) }
    if ($IconUri) { $ManifestProperties.Add('IconUri', $IconUri) }
    if ($ReleaseNotes) { $ManifestProperties.Add('ReleaseNotes', $ReleaseNotes) }
    if ($ProjectUri) { $ManifestProperties.Add('ProjectUri', $ProjectUri) }
    if ($LicenseUri) { $ManifestProperties.Add('LicenseUri', $LicenseUri) }

    New-ModuleManifest @ManifestProperties
}