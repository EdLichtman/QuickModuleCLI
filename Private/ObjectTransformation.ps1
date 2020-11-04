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
