function global:ConvertTo-PowershellEncodedString {
    param(
        $object
    )
        $objectHasProperties = $object.Keys;
        $objectType = $object.GetType();
        $objectIsArray = $objectType.ImplementedInterfaces.Contains([System.Collections.IList]);
        
        if ($objectHasProperties) {
            return @"
@{
    $(($object.Keys | ForEach-Object {"$_ = $(ConvertTo-PowershellEncodedString $object[$_])"}) -join "`r`n")
}

"@;
        } elseif ($objectIsArray) {
            return @"
@(
    $(($object | ForEach-Object {ConvertTo-PowershellEncodedString $_}) -join ",`r`n")
)
"@;
        } else {
            if ($objectType -eq [String]) {
                return "'$object'"
            }
            return $object
        }
}