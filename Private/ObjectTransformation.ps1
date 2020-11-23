function Select-Property{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [Object]
        $Obj,
        [Parameter(Mandatory=$True)]
        [String]
        $Property
    )
    process {
        return , @($Obj."$Property")
    }
}

<#TODO: TEST#>
function Get-ReducedPopulatedHashtable {
    [OutputType([Hashtable])]
    <#
.Synopsis
Given a Hashtable and a set of keys, this reduces the Hashtable into only those values that are contained within those keys.
    #>
    param (
        [Hashtable] $InputTable,
        [String[]] $Keys
    )
    $returnValue = @{}
    foreach($Key in $Keys) {
        if ($InputTable.ContainsKey($Key)) { $returnValue[$Key] = $InputTable[$Key] }
    }
    return $returnValue
}