function Set-ModuleVariable {
    [CmdletBinding(SupportsShouldProcess=$False)]
    param(
            
            [string]$Name,
            [object]$Value,
            [switch]$PassThru)

    Set-Variable -Force:$true -Name $Name -Value $Value -Visibility Public -Scope Script -WhatIf:$false
    if($PassThru) {
        $Value
    }

}