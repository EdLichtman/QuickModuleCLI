Function Test-CommandExists {
    Param (
        [String] $command
    )
    
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {if(Get-Command $command){return $true}}
    Catch {return $false}
    Finally {$ErrorActionPreference=$oldPreference}
}