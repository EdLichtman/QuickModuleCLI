function global:ConvertTo-PowershellEncodedString {
    param(
        $object
    )
        $objectHasProperties = $object.Keys;
        $objectType = $object.GetType();
        $objectIsArray = $objectType.ImplementedInterfaces.Contains([System.Collections.IList]);
        
        if ($objectHasProperties) {
            if ($object.Keys) {
                return @"
@{
    $(($object.Keys | ForEach-Object {"$_ = $(ConvertTo-PowershellEncodedString $object[$_])"}) -join "`r`n")
}               
"@;
            }
            return "@{}";
        } elseif ($objectIsArray) {
            if ($object.Count) {
                return @"
@(
    $(($object | ForEach-Object {ConvertTo-PowershellEncodedString $_}) -join ",`r`n")
)
"@;
            }
           return "@()"
        } else {
            if ($objectType -eq [String]) {
                return "'$object'"
            }
            return $object
        }
}