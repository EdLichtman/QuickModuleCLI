function global:Show-CommandContent {
        param(
        [String] $commandName
    )

    . "$PSScriptRoot\..\Required\Reserved\Test-QuickFunctionVariable.ps1"
    $commandName = Test-QuickFunctionVariable $PSBoundParameters 'commandName' 'Enter the command to define'

    $commandText = Get-Command $commandName | Select-Object -ExpandProperty Definition;
    Write-Output $commandText

}