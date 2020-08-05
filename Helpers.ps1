Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {if(Get-Command $command){return $true}}
    Catch {return $false}
    Finally {$ErrorActionPreference=$oldPreference}
}

function Refresh-Profile {
    . $profile
}

function Create-FolderIfNotExists {
    param([String] $pathToFolder)

    if (!(Test-Path $pathToFolder -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $pathToFolder | Out-null
    }
}

function Force-CreateFile {
    param([String] $pathToFile)
    if (!(Test-Path $pathToFile)) {
        New-Item -ItemType File -Force -Path $pathToFile | Out-null
    }
}

function Create-FileIfNotExists {
    param(  [String] $filePath,
            [String] $fileText)
    if (!(Test-Path $filePath)) {
        Force-CreateFile -pathToFile $filePath
        $fileText | Add-Content -Path $filePath 
    }
}

function Create-FileWithContent {
    param(  [String] $filePath,
            [String] $fileText)
    if (Test-Path $filePath) {
        $folderPath = Split-Path $filePath
        $fileName = Split-Path $filePath -Leaf
        $continue = Read-Host "File by the name $fileName already exists at location $folderPath. Would you like to overwrite? (Y/N)"
        if ($continue -eq 'y') {
            Remove-Item $filePath
        }
    } else {
        $continue = 'y'
    }
    if ($continue -eq 'y') {
        Force-CreateFile -pathToFile $filePath
        Add-Content -Path $filePath -Value $fileText 
    }
}

function Finalize-UserPrompt {
    Write-Output "Please close and re-open your PowerShell Sessions."
}

function Get-FunctionNames {
    param([String] $functionBlock)
    $functionOnSingleLine = $functionBlock -replace "`n"," " -replace "`r"," "
    $functionNamesCapture = $functionOnSingleLine | Select-String -Pattern '.*function ([^ ]*) .*'
    
    $functionNamesMatches = $functionNamesCapture.Matches;
    $functionNamesMatches.RemoveAt(0);
    
    return $functionNamesMatches;
}
