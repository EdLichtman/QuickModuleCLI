function Add-UDTool {

    . $PSScriptRoot\Get-UDPowershellEnvironment.ps1
    . $PSScriptRoot\Set-UDToolsPath.ps1
    . $PSScriptRoot\Add-UDOneLineFunction.ps1

    $toolsDir = $env:Tools
    if ([String]::IsNullOrWhiteSpace($toolsDir)) {
        Set-UDToolsPath
    } 

    $pathToNewTool = Read-Host "Please add the path to the EXE. If you start with '\' the relative path will be: $($toolsDir)"
    if ($pathToNewTool.StartsWith("\")) {
        $pathToNewTool = "$($toolsDir)$pathToNewTool"
    }

    $CommandName = $pathToNewTool.Replace('.exe','').Substring($pathToNewTool.LastIndexOf("\")+1);
    Write-Output "Adding Tool 'Run-$CommandName'."

    Add-UDOneLineFunction -functionName "Run-$CommandName" -functionText "& '$pathToNewTool'"
}