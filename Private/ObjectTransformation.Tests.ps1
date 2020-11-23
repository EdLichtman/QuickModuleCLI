# describe 'ObjectTransformation' {
#     describe 'Select-Property' {
#         it 'Can select a single property into an array' {
#             $fileInfos2 = @((Get-MockFileInfo $expectedFirstFileInfoName))
#             $fileNames2 = $fileInfos2 | Select-Property -Property 'BaseName'

#             ($fileNames2[0]) | Should -Be $expectedFirstFileInfoName
#         }

#         it 'Can select multiple properties into an array' {
#             $expectedFirstFileInfoName = 'Foo'
#             $fileInfos = @((Get-MockFileInfo $expectedFirstFileInfoName),(Get-MockFileInfo 'bar'))
#             $fileNames = $fileInfos | Select-Property -Property 'BaseName'
    
#             ($fileNames[0]) | Should -Be $expectedFirstFileInfoName
#         }
#     }
# }