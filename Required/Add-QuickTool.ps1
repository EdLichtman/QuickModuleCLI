function global:Add-QuickTool {

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $PSScriptRoot\Set-QuickToolsPath.ps1
    . $PSScriptRoot\Add-QuickOneLineFunction.ps1
    . $PSScriptRoot\Set-Env.ps1

    $toolsDir = $env:Tools
    if ([String]::IsNullOrWhiteSpace($toolsDir)) {
        $toolsPath = Read-Host "Please enter path to Tools Directory"
        Set-Env 'Tools' $toolsPath
    } 

    $pathToNewTool = Read-Host "Please add the path to the EXE. If you start with '\' the relative path will be: $($toolsDir)"
    if ($pathToNewTool.StartsWith("\")) {
        $pathToNewTool = "$($toolsDir)$pathToNewTool"
    }

    $CommandName = $pathToNewTool.Replace('.exe','').Substring($pathToNewTool.LastIndexOf("\")+1);
    Write-Output "Adding Tool 'Run-$CommandName'."

    Add-QuickOneLineFunction -functionName "Run-$CommandName" -functionText "& '$pathToNewTool'"
}