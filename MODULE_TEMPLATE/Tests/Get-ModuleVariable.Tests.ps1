$myModule = Import-Module (Get-ChildItem "$PSScriptRoot\..\Source\*.psm1" | Select-Object -ExpandProperty FullName -first 1) -force -PassThru

Describe 'Get-ModuleVariable' {
    InModuleScope $myModule.Name {
        Context 'Running without arguments'   {
            It 'requires name parameter' {           
                { Get-ModuleVariable } | Should Throw
            }
        }
  
        Context 'Getting module variables'   {
            Set-ModuleVariable -Name TestModuleName1 -Value TestModuleValue1
            Set-ModuleVariable -Name EmptyVariable1 -Value ''
            It 'runs without errors' {
                Get-ModuleVariable -name TestModuleName1 | Should Be TestModuleValue1     
            }   
        
            It 'throws error if variable does not exist' {
                { Get-ModuleVariable -Name DoesnotExistVariable } | Should Throw
            }
        
            It 'does not throw error if variable does not exist and a DefaultValue is specified' {
                Get-ModuleVariable -Name DoesnotExistVariable -DefaultValue 'MyDefault'
            }        
        
            It 'does not throw error if variable does not exist and AllowNotSet switch is used' {
                Get-ModuleVariable -Name DoesNotExistVariable
            }
        
            It 'does not allow empty values when "DoNotAllowEmpty" switch is used' {
                { Get-ModuleVariable -Name EmptyVariable1 -DoNotAllowEmpty } | Should Throw
            }
        
            It 'does not allow empty values when "DoNotAllowEmpty" switch is used even when a DefaultValue is specified' {
                { Get-ModuleVariable -Name EmptyVariable1 -DoNotAllowEmpty -DefaultValue 'MyDefault' } | Should Throw
            }   
        
            It 'returns an empty value if the variable was never set and the AllowNotSet parameter is specified' {
                Get-ModuleVariable -Name DoesNotExistVariable2  -AllowNotSet | Should BeNullOrEmpty 
            }      
        }
    }
}
