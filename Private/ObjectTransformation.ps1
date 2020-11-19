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
Given the $PSBoundParameters, an object to populate and a set of keys, 
this creates an object from the input parameters.
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