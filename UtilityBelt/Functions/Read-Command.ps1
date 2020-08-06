function Read-Command {
        param(
        [String] $commandName
    )

    $commandName = Test-UDFunctionVariable $PSBoundParameters 'commandName' 'Enter the command to define'

    $commandText = Get-Command $commandName | Select-Object -ExpandProperty Definition;
    Write-Output $commandText

}