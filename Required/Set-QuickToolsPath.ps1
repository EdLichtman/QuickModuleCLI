function Set-QuickToolsPath {
    $toolsPath = Read-Host "Please enter path to Tools Directory"
    [System.Environment]::SetEnvironmentVariable('Tools',$toolsPath,[System.EnvironmentVariableTarget]::User)
}