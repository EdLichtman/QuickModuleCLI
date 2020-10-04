function Get-MockImportsHeader {
    $ModuleHome = "$PSScriptRoot\..\..\"

    return {
        $FilesToImport = @(Get-ChildItem -Recurse "ModuleHome" -Filter '*.ps1' | ForEach-Object { "$($_.FullName)" }) | Where-Object {!($_.Contains('Tests.ps1'))}
        foreach ($file in $FilesToImport) {
            . $file
        }
        Mock Invoke-Expression -ParameterFilter {$Command -Match '. *'}
    }.ToString() -replace "ModuleHome", $ModuleHome
}

function Get-TestImportsHeader {
    $ModuleHome = "$PSScriptRoot\..\..\"
    return {
        . "ModuleHome\Required\Reserved\Get-QuickEnvironment.ps1"
        Mock Exit-AfterImport { return $true; }
        Mock Test-ImportCompleted
    }.ToString() -replace "ModuleHome", $ModuleHome
}