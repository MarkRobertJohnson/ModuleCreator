$myModule = Import-Module (Get-ChildItem "$PSScriptRoot\..\Source\*.psm1" | Select-Object -ExpandProperty FullName -first 1) -force -PassThru

Describe 'Set-ModuleVariable' {
    Context 'Running without arguments'   {
        It 'requires name and value parameters' {
            { Set-ModuleVariable } | Should Throw
        }
    }
  
    Context 'Setting module variables'   {
        # test 1: it does not throw an exception:
        It 'runs without errors' {
            { Set-ModuleVariable -name TestModuleName1 -Value TestModuleValue1} | Should Not Throw        
        }
        
        It 'does not expose the variable outside the module' {
            Set-ModuleVariable -name TestModuleName1 -Value TestModuleValue1 | Should BeNullOrEmpty 
            Get-Variable -Name TestModuleName1 -ErrorAction SilentlyContinue | Should BeNullOrEmpty
            Get-ModuleVariable -Name TestModuleName1 | Should Be TestModuleValue1
        }
        
        It 'can passthru the variable value that was set' {
            Set-ModuleVariable -name TestModuleName1 -Value TestModuleValue1 -PassThru | Should Be TestModuleValue1
        }
        
    }
  
}
