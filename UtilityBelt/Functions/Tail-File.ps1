function Get-RealtimeFileContents {
    param(
        [Parameter(Mandatory=$true)][String]$filePath,
        [Int32]$lines
    )
    Get-Content $filePath -Tail $lines -Wait
}