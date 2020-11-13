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
function Add-InputParametersToObject {
    <#
.Synopsis
Given the $PSBoundParameters, an object to populate and a set of keys, 
this creates an object from the input parameters.
    #>
    param (
        [Hashtable] $BoundParameters,
        [Object] $ObjectToPopulate,
        [String[]] $Keys
    )
    foreach($Key in $Keys) {
        if ($BoundParameters.ContainsKey($Key)) { $ObjectToPopulate[$Key] = $BoundParameters[$Key] }
    }
}