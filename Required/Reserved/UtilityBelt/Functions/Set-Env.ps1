function global:Set-Env {
    param (
        [String] $variable,
        [String] $value
    )

    if (!$PSBoundParameters.ContainsKey('variable')) {
        $variable = Read-Host 'Please enter Environment Variable Name'
    }

    $existingVariable = [System.Environment]::GetEnvironmentVariable($variable,[System.EnvironmentVariableTarget]::User);
    if (![String]::IsNullOrWhiteSpace($existingVariable)) {
        $continue = Read-Host 'A value already exists at that location. Would you like to overwrite? (Y/N)'
        if (!($continue -eq 'y')) {
            return;
        }
    }

    if (!$PSBoundParameters.ContainsKey('value')) {
        $value = Read-Host 'Please enter Environment Variable Value'
    }
    [System.Environment]::SetEnvironmentVariable($variable,$value,[System.EnvironmentVariableTarget]::User)
}