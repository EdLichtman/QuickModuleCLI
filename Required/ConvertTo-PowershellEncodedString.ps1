function global:ConvertTo-PowershellEncodedString {
    param(
        $object
    )
        $objectHasProperties = $object.Keys;
        $objectType = $object.GetType();
        $objectIsArray = $objectType.ImplementedInterfaces.Contains([System.Collections.IList]);
        
        if ($objectHasProperties) {
            return "@{$(($object.Keys | ForEach-Object {"$_ = $(ConvertTo-PowershellEncodedString $object[$_])"}) -join ';')}";
        } elseif ($objectIsArray) {
            return "@($(($object | ForEach-Object {ConvertTo-PowershellEncodedString $_}) -join ','))";
        } else {
            if ($objectType -eq [String]) {
                return "'$object'"
            }
            return $object
        }
}
$string = "foo"
$array = @(1,2,3)
$object = @{
    foo = "bar"
}
$objectWithArray = @{
    foo = "bar"
    bar = @(1,2,3)
}
$objectWithObject = @{
    foo = "bar"
    bar = @{
        fur = "bur"
    }
}

Write-Output "String"
ConvertTo-PowershellEncodedString $string
Write-Output "Array"
ConvertTo-PowershellEncodedString $array
Write-Output "Object"
ConvertTo-PowershellEncodedString $object
Write-Output "ObjectWithArray"
ConvertTo-PowershellEncodedString $objectWithArray
Write-Output "ObjectWithObject"
ConvertTo-PowershellEncodedString $objectWithObject
