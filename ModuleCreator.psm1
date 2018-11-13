[CmdletBinding()]
param([switch]$verbose)

$ErrorActionPreference = 'stop'
$ModuleRoot = $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase

. "$ModuleRoot\Scripts\PreLoad.ps1" -ModuleRoot $ModuleRoot

$functionNamesToExport = . "$ModuleRoot\Scripts\Load-AllModuleFunctions.ps1" -ModuleRoot $ModuleRoot

Export-ModuleMember -Function $functionNamesToExport -Alias *

. "$ModuleRoot\Scripts\PostLoad.ps1" -ModuleRoot $ModuleRoot