# throw 'This needs to be rewritten since I gouged out the Add-ModuleFunction'
# Describe 'Add-ModuleFunction' {
#     BeforeAll {
#         . "$PSScriptRoot\Reserved\Get-TestHeaders.ps1"
#         . "$PSScriptRoot\Add-ModuleFunction.ps1"

#         Invoke-Expression (Get-MockImportsHeader)
#     }

#     It "requests FunctionName if no name is provided" {
#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return ""} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-ModuleFunction -FunctionText ''

#         Assert-MockCalled Test-ModuleFunctionVariable -ParameterFilter { $variableName -eq 'functionName' } 
#     }

#     It "requests FunctionText if no text is provided" {
#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return ""} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-ModuleFunction -functionName 'Get-Test'

#         Assert-MockCalled Test-ModuleFunctionVariable -ParameterFilter { $variableName -eq 'functionText' }
#     }

#     It "automatically replaces semi-colons with line breaks" {
#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return "Write-Output 'hello';return;"} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         # 2nd-to-last line of function contains 4 spaces
#         $expectedFileText = 
# @"
# function global:Get-Test {
#     Write-Output 'hello';
#     return;
    
# }
# "@

#         Add-ModuleFunction -functionName 'Get-Test'

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $expectedFileText }
#     }

#     It "does not replace semi-colons within single-quote strings" {
#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return "Write-Output 'hello; world';return;"} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         # 2nd-to-last line of function contains 4 spaces
#         $expectedFileText = 
# @"
# function global:Get-Test {
#     Write-Output 'hello; world';
#     return;
    
# }
# "@

#         Add-ModuleFunction -functionName 'Get-Test'

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $expectedFileText }
#     }

#     It "does not replace semi-colons within double-quote strings" {
#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return 'Write-Output "hello; world";return;'} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         # 2nd-to-last line of function contains 4 spaces
#         $expectedFileText = 
# @"
# function global:Get-Test {
#     Write-Output "hello; world";
#     return;
    
# }
# "@

#         Add-ModuleFunction -functionName 'Get-Test'

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $expectedFileText }
#     }

#     It "Allows raw input to write directly to file" {
#         $rawFunction = "function Get-Test{}"
#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return $rawFunction} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-ModuleFunction -functionName 'Get-Test' -functionText $rawFunction -Raw

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $rawFunction }
#     }

#     It "does not allow unapproved verbs in a function name" {
#         Mock Test-ModuleFunctionVariable { return "Foo-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return ''} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         {Add-ModuleFunction -functionName 'Foo-Test' -functionText ''} | Should -Throw -ExceptionType ([System.ArgumentException])

#     }

#     It "creates a function at the specified Functions Location" {
#         $ModuleFunctionsRoot = "$PSScriptRoot\TestFunctions"

#         Mock Test-ModuleFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-ModuleFunctionVariable { return ''} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-ModuleFunction -functionName 'Get-Test' -functionText ''

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $filePath -eq "$ModuleFunctionsRoot\Get-Test.ps1" }
#     }
# }

# Describe "Add-ModuleFunction Integration" {
#     BeforeAll {
#         #Import Test Header and Functions We're testing
#         . "$PSScriptRoot\Reserved\Get-TestHeaders.ps1"
#         . "$PSScriptRoot\Add-ModuleFunction.ps1"

#         #Run Get-MockImportsHeader to Import all functions
#         Invoke-Expression (Get-MockImportsHeader)


#         #Overwrite Environment variables. Double up Parameter for Safety precautions. 
#         $TestFunctionsRoot = "$PSScriptRoot\..\Test"
#         $ModuleFunctionsRoot = $TestFunctionsRoot
#         $PrivateFunctionsFolder = "$PSScriptRoot\Reserved"
        
#         # Create Test Folder
#         New-Item $ModuleFunctionsRoot -ItemType 'Container'
#     }

#     AfterAll {
#         # Destroy Test Folder using Test variable instead of Environment variable just in case
#         Remove-Item $TestFunctionsRoot -Recurse -Force
#     }

#     It "actually creates the function requested" {
#         Add-ModuleFunction -functionName "Test-FileCreation" -functionText ""

#         $doesFunctionExist = (Test-Path "$ModuleFunctionsRoot\Test-FileCreation.ps1")
#         $doesFunctionExist | Should -Be $true
#     }
# }

# Describe 'Add-Function Imports' {
#     BeforeAll {
#         . "$PSScriptRoot\Reserved\Get-TestHeaders.ps1"
#         . "$PSScriptRoot\Add-ModuleFunction.ps1"
#     }
#     It "Successfully imports all files" {
#         Invoke-Expression (Get-TestImportsHeader)
#         # Should throw AssertionError if any Imports are missing
#         Add-ModuleFunction

#         Assert-MockCalled Test-ImportCompleted -Times 1
#     }
# }