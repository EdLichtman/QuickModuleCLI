param([Switch]$Force)

$PowershellUserProfileRoot = Split-Path $profile
$functionsRoot = "$PowershellUserProfileRoot\Functions"
$aliasesRoot = "$PowershellUserProfileRoot\Aliases"
$aliasMappingFile = "$aliasesRoot\map.json"

. $PSScriptRoot\Helpers.ps1
Create-FolderIfNotExists($PowershellUserProfileRoot)
Create-FolderIfNotExists($functionsRoot)
Create-FolderIfNotExists($aliasesRoot)

Create-FileIfNotExists -filePath $aliasMappingFile -fileText '{}' 
$aliasMapping = @{}
$aliasMappingJson = Get-Content $aliasMappingFile | Out-String
(ConvertFrom-Json $aliasMappingJson).psobject.properties | ForEach {$aliasMapping[$_.Name] = $_.Value}

function Add-CustomOneLineFunction {
    param(
        [string]$functionName,
        [string]$functionText
    )
    if ([String]::IsNullOrWhiteSpace($functionName)){
        $functionName = Read-Host "Please enter the Command Name to Run"
        # Only show prompt if $functionName is not included because if $functionName exists $functionText may be intentionally blank
        $functionText = Read-Host "Please enter the One-Line Function"
    }
    
    $functionText = Read-Host "Please enter the One-Line Function"

    $newCode = 
@"
function $FunctionName {
    $FunctionText
}
"@
    Create-FileWithContent -filePath "$functionsRoot\$FunctionName.ps1" -fileText $newCode
    Refresh-Profile
}

function Add-CustomFunction {
    param(
        [string]$functionName
    )
    if ([String]::IsNullOrWhiteSpace($functionName)){
        $functionName = Read-Host "Please enter the Command Name to Run"
    }

    Add-CustomOneLineFunction -functionName $functionName -functionText ''
    powershell_ise.exe "$functionsRoot\$FunctionName.ps1"
}

function Add-CustomAlias {
    param(
        [string]$AliasName,
        [string]$AliasText
    )
    if ([String]::IsNullOrWhiteSpace($AliasName)){
        $AliasName = Read-Host "Please enter the alias"
    }
    if ([String]::IsNullOrWhiteSpace($AliasText)){
        $AliasText = Read-Host "Please enter the Command Name"
    }

    if ($aliasMapping.ContainsKey($AliasName) -or $aliasMapping.ContainsKey($aliasText)) {
        Write-Output "Alias or Function already exists by that name. Please try again."
        return
    }
    $aliasMapping[$aliasText] = $aliasName
    $aliasMapping[$aliasName] = $aliasText
    

    $newCode = "Set-Alias $AliasName $AliasText"
    Create-FileWithContent -filePath "$aliasesRoot\$AliasName.ps1" -fileText $newCode
    $aliasMapping | ConvertTo-Json | Set-Content $aliasMappingFile
    Refresh-Profile
}

function Remove-CustomAlias {
    param(
        [String]$aliasName
    )
    if ([String]::IsNullOrWhiteSpace($aliasName)) {
        $aliasName = Read-Host "Please enter the CustomAlias Name to delete"
    }
    Remove-Item -Path "$aliasesRoot\$aliasName.ps1"
    $functionName = $aliasMapping[$aliasName]
    $aliasMapping.Remove($aliasName)
    $aliasMapping.Remove($functionName)
    $aliasMapping | ConvertTo-Json | Set-Content $aliasMappingFile
    
    Remove-Item alias:\$aliasName

    Refresh-Profile
}

function Remove-CustomFunction {
    param(
        [String]$functionName,
        [Switch]$force
        )
    if ([String]::IsNullOrWhiteSpace($functionName)) {
        $FunctionName = Read-Host "Please enter the CustomFunction Name to delete"
    }

    if (!$Force -and $aliasMapping.ContainsKey($functionName)){
        $continue = Read-Host "Deleting '$functionName' will also delete alias '$($aliasMapping[$functionName])'. Continue? (Y/N)"
    } else {
        $continue = 'y'
    }
    if ($continue -eq 'y') {
        Remove-Item -Path "$functionsRoot\$functionName.ps1"
        if ($aliasMapping.ContainsKey($functionName)) {
            Remove-CustomAlias $aliasMapping[$functionName]
        }
    }
}

function Edit-CustomFunction {
    param(
        [String]$functionName
    )
    if ([String]::IsNullOrWhiteSpace($functionName)) {
        $FunctionName = Read-Host "Please enter the CustomFunction Name to edit"
    }
    . powershell_ise.exe "$functionsRoot\$functionName.ps1"
}

function Edit-CustomAlias {
    param(
        [String]$aliasName
    )
    if ([String]::IsNullOrWhiteSpace($functionName)) {
        $aliasName = Read-Host "Please enter the Alias to edit"
    }
    . powershell_ise.exe "$aliasesRoot\$aliasName.ps1"
}

function Rename-CustomFunction {
    $FunctionName = Read-Host "Please enter the CustomFunction Name to be Renamed"
    $NewFunctionName = Read-Host "Please enter the new Name"
    $filePath = "$functionsRoot\$functionName.ps1"
    if (!(Test-Path $filePath)) {
        Write-Output "CustomFunction '$functionName' does not exist".
    }

    $FunctionBlock = Get-Content $filePath -Raw
    $NewFunctionBlock = $FunctionBlock -Replace "$FunctionName", "$NewFunctionName"

    $alias = $aliasMapping[$FunctionName]

    Remove-CustomFunction -functionName $FunctionName -force
    Create-FileWithContent -filePath "$functionsRoot\$NewFunctionName.ps1" -fileText $NewFunctionBlock

    if (![String]::IsNullOrWhiteSpace($alias)){
        Add-CustomAlias -AliasName $alias -aliasText $NewFunctionName
    }
}

function Set-ToolsPath {
    $toolsPath = Read-Host "Please enter path to Tools Directory"
    [System.Environment]::SetEnvironmentVariable('Tools',$toolsPath,[System.EnvironmentVariableTarget]::User)
    Refresh-Profile
}

function Add-Tool {
    $toolsDir = $env:Tools
    if ([String]::IsNullOrWhiteSpace($toolsDir)) {
        Set-ToolsPath
    } 

    $pathToNewTool = Read-Host "Please add the path to the EXE. If you start with '\' the relative path will be: $($env:tools)"
    if ($pathToNewTool.StartsWith("\")) {
        $pathToNewTool = "$($env:Tools)$pathToNewTool"
    }

    $CommandName = $pathToNewTool.Replace('.exe','').Substring($pathToNewTool.LastIndexOf("\")+1);
    $NewCommandName = Read-Host "Adding Tool 'Run-$CommandName'. Press Enter to accept, or type a new Tool Run-Function"

    if ([String]::IsNullOrWhiteSpace($NewCommandName)){
        $NewCommandName = "Run-$CommandName"
    }

    Add-CustomOneLineFunction -functionName $NewCommandName -functionText "& '$pathToNewTool'"
}

function Get-CustomFunctions {
    $functions = Get-ChildItem $functionsRoot -Filter "*.ps1"
    foreach($function in $functions) {
        Write-Output "`r$($function.Name -replace '.ps1', '')"
    }
    Write-Output "`r";
}

function Describe-CustomFunction {
    param(
        [String]$functionName
    )
    if ([String]::IsNullOrWhiteSpace($functionName)) {
        $FunctionName = Read-Host "Please enter the CustomFunction Name to describe"
    }

    $filePath = "$functionsRoot\$functionName.ps1"

    if (!(Test-Path $filePath)) {
        Write-Output "No such CustomFunction found."
    }

    Write-Output ("`r" + (Get-Content $filePath -Raw) + "`r")
}

$functions = Get-ChildItem $functionsRoot -Filter "*.ps1"
foreach($function in $functions) {
    . $functionsRoot\$function
}
$aliases = Get-ChildItem $aliasesRoot -Filter "*.ps1"
foreach($alias in $aliases) {
    . $aliasesRoot\$alias
}

$PowershellProfilePath = "$PowershellUserProfileRoot\Microsoft.PowerShell_profile.ps1"
$HelpersPath = "$PowershellUserProfileRoot\Helpers.ps1"

if ($Force) {
    if (Test-Path $PowershellProfilePath) {
        Remove-Item $PowershellProfilePath
    }

    if (Test-Path $HelpersPath) {
        Remove-Item $HelpersPath
    }
}
Create-FileIfNotExists -FilePath $PowershellProfilePath -FileText (Get-Content $PSCommandPath -Raw) 
Create-FileIfNotExists -FilePath $HelpersPath -FileText (Get-Content "$PSScriptRoot\Helpers.ps1" -Raw) 
