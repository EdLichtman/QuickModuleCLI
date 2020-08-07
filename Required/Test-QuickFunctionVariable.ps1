function Test-QuickFunctionVariable {
    param(
        [hashtable]$Parameters,
        [String]$variableName,
        [String]$Prompt
    )
    if (($Parameters -eq $null) -or !$Parameters.ContainsKey($variableName)){
        return Read-Host $prompt
    }
    return $Parameters[$variableName]
}