<#TODO: Test#> 
function Confirm-Choice {
    param(
        [Parameter(Mandatory=$True)][String]$Title,
        [Parameter(Mandatory=$True)][String]$Prompt,
        [Parameter(Mandatory=$False)][Switch]$DefaultsToYes
    )
    $Default = if ($DefaultsToYes) {
        0
    } else {
        1
    }
    return ($Host.UI.PromptForChoice($Title,$Prompt,@('&Yes','&No'), $Default) -eq 0)
}

<#TODO: MOVE THIS TO NEW PRIVATE FUNCTIONS FILE#>
function Wait-ForKeyPress {
    Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
    $null = (Get-HostUI).RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

<#TODO: MOVE THIS TO NEW PRIVATE FUNCTIONS FILE#>
function Open-PowershellEditor{ 
    param([String]$Path)
    powershell.exe $Path
}
