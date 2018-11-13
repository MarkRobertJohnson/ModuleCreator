function Get-ModuleVariable {
     [CmdletBinding()]
     param(
        [string]$Name = (throw "The Name parameter is required"),
        [switch]$DoNotAllowEmpty,
        [switch]$AllowNotSet,
        [AllowNull()][Object]$DefaultValue,
     [string]$ErrorMessage = "The '$Name' variable is not set.")

    $var = Get-Variable -Name $Name -ErrorAction SilentlyContinue
    

    #Case 1: The variable does not exist and no default value was set
    if(-not $DefaultValue -and ((-not $var -and -not $AllowNotSet))) {
        throw $ErrorMessage
    }

    #Case 2: The variable exists, but it has no value
    if($var -and -not $var.Value -and $DoNotAllowEmpty) {
        throw "The '$Name' variable is set, but it has an empty or null value and the '-DoNotAllowEmpty' switch was specified"
    }
    
    #Case 3: The variable does not exist, and the default was specified
    if($DefaultValue -and (-not $var -or -not $var.Value)) {
        Set-ModuleVariable -Name $Name -Value $DefaultValue -PassThru
    } else {
        $var.Value
    }
}