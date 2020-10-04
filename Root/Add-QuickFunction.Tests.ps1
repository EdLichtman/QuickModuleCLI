# throw 'This needs to be rewritten since I gouged out the Add-QuickFunction'
# Describe 'Add-QuickFunction' {
#     BeforeAll {
#         . "$PSScriptRoot\Reserved\Get-TestHeaders.ps1"
#         . "$PSScriptRoot\Add-QuickFunction.ps1"

#         Invoke-Expression (Get-MockImportsHeader)
#     }

#     It "requests FunctionName if no name is provided" {
#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return ""} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-QuickFunction -FunctionText ''

#         Assert-MockCalled Test-QuickFunctionVariable -ParameterFilter { $variableName -eq 'functionName' } 
#     }

#     It "requests FunctionText if no text is provided" {
#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return ""} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-QuickFunction -functionName 'Get-Test'

#         Assert-MockCalled Test-QuickFunctionVariable -ParameterFilter { $variableName -eq 'functionText' }
#     }

#     It "automatically replaces semi-colons with line breaks" {
#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return "Write-Output 'hello';return;"} -ParameterFilter {$variableName -eq 'functionText'}
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

#         Add-QuickFunction -functionName 'Get-Test'

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $expectedFileText }
#     }

#     It "does not replace semi-colons within single-quote strings" {
#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return "Write-Output 'hello; world';return;"} -ParameterFilter {$variableName -eq 'functionText'}
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

#         Add-QuickFunction -functionName 'Get-Test'

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $expectedFileText }
#     }

#     It "does not replace semi-colons within double-quote strings" {
#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return 'Write-Output "hello; world";return;'} -ParameterFilter {$variableName -eq 'functionText'}
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

#         Add-QuickFunction -functionName 'Get-Test'

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $expectedFileText }
#     }

#     It "Allows raw input to write directly to file" {
#         $rawFunction = "function Get-Test{}"
#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return $rawFunction} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-QuickFunction -functionName 'Get-Test' -functionText $rawFunction -Raw

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $fileText -eq $rawFunction }
#     }

#     It "does not allow unapproved verbs in a function name" {
#         Mock Test-QuickFunctionVariable { return "Foo-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return ''} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         {Add-QuickFunction -functionName 'Foo-Test' -functionText ''} | Should -Throw -ExceptionType ([System.ArgumentException])

#     }

#     It "creates a function at the specified Functions Location" {
#         $QuickFunctionsRoot = "$PSScriptRoot\TestFunctions"

#         Mock Test-QuickFunctionVariable { return "Get-Test"} -ParameterFilter {$variableName -eq 'functionName'}
#         Mock Test-QuickFunctionVariable { return ''} -ParameterFilter {$variableName -eq 'functionText'}
#         Mock New-FileWithContent
#         Mock Invoke-Expression

#         Add-QuickFunction -functionName 'Get-Test' -functionText ''

#         Assert-MockCalled New-FileWithContent -ParameterFilter { $filePath -eq "$QuickFunctionsRoot\Get-Test.ps1" }
#     }
# }

# Describe "Add-QuickFunction Integration" {
#     BeforeAll {
#         #Import Test Header and Functions We're testing
#         . "$PSScriptRoot\Reserved\Get-TestHeaders.ps1"
#         . "$PSScriptRoot\Add-QuickFunction.ps1"

#         #Run Get-MockImportsHeader to Import all functions
#         Invoke-Expression (Get-MockImportsHeader)


#         #Overwrite Environment variables. Double up Parameter for Safety precautions. 
#         $TestFunctionsRoot = "$PSScriptRoot\..\Test"
#         $QuickFunctionsRoot = $TestFunctionsRoot
#         $QuickReservedHelpersRoot = "$PSScriptRoot\Reserved"
        
#         # Create Test Folder
#         New-Item $QuickFunctionsRoot -ItemType 'Container'
#     }

#     AfterAll {
#         # Destroy Test Folder using Test variable instead of Environment variable just in case
#         Remove-Item $TestFunctionsRoot -Recurse -Force
#     }

#     It "actually creates the function requested" {
#         Add-QuickFunction -functionName "Test-FileCreation" -functionText ""

#         $doesFunctionExist = (Test-Path "$QuickFunctionsRoot\Test-FileCreation.ps1")
#         $doesFunctionExist | Should -Be $true
#     }
# }

# Describe 'Add-Function Imports' {
#     BeforeAll {
#         . "$PSScriptRoot\Reserved\Get-TestHeaders.ps1"
#         . "$PSScriptRoot\Add-QuickFunction.ps1"
#     }
#     It "Successfully imports all files" {
#         Invoke-Expression (Get-TestImportsHeader)
#         # Should throw AssertionError if any Imports are missing
#         Add-QuickFunction

#         Assert-MockCalled Test-ImportCompleted -Times 1
#     }
# }