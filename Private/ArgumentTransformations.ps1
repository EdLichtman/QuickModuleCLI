using namespace System.Management.Automation
# [System.Management.Automation.ArgumentTransformationAttribute]

function Get-SemicolonCreatesLineBreakTransformation {
    param($inputData)
    $newValue = ""
                
    $DoesInputEndInSemicolon = $inputData.TrimEnd(' ').EndsWith(';')
    $IndexOfLastSemicolon = $inputData.LastIndexOf(';');
    $NumberOfSingleQuotes = 0
    $NumberOfDoubleQuotes = 0

    $inputDataCharacterArray = [char[]]$inputData
    for($i = 0; $i -lt $inputDataCharacterArray.Length; $i++) {
        $character = $inputDataCharacterArray[$i]
        if ($character -eq "'") {
            $NumberOfSingleQuotes++
        }
        if ($character -eq '"') {
            $NumberOfDoubleQuotes++
        }
        if (($NumberOfDoubleQuotes % 2 -eq 0) -and ($NumberOfSingleQuotes % 2 -eq 0) -and ($character -eq ';')) {
            if ($DoesInputEndInSemicolon -and ($i -eq $IndexOfLastSemicolon )) {
                $newValue += ";"
            } else {
                $newValue += ";`r`n"
            }
        } else {
            $newValue += $character
        }
    }

    return $newValue
}
class SemicolonCreatesLineBreakTransformationAttribute : ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData)
    {
        if ($inputData -is [string])
        {
            return Get-SemicolonCreatesLineBreakTransformation $inputData
        }
        
        # anything else throws an exception:
        throw [System.ArgumentException]::new("String expected, but was $($inputData.GetType().Name).")
    }
}