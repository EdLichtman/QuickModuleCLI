function Invoke-External {
    param(
      [Parameter(Mandatory=$true)]
      [string] $LiteralPath,
      [Parameter(ValueFromRemainingArguments=$true)]
      $PassThruArgs
    )
    & $LiteralPath $PassThruArgs
}

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

function Wait-ForKeyPress {
    Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Open-PowershellEditor { 
    param([String]$Path)
    Start-Process "$Path"
}

function Get-EnvironmentModuleDirectories {
    return ($env:PSModulePath.Split(';') | ForEach-Object { Get-Item $_ }).FullName
}