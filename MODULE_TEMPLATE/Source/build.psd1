@{
    Path = "[[$TemplateModuleName]].psd1"
    OutputDirectory = "../output/[[$TemplateModuleName]]"
    VersionedOutputDirectory = $false
    CopyDirectories = @('Scripts')
    Prefix = @'
$ModuleRoot = $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase
. $ModuleRoot\Scripts\PreLoad.ps1 -ModuleRoot $ModuleRoot
'@
    Suffix = @'
$ModuleRoot = $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase
. $ModuleRoot\Scripts\PostLoad.ps1 -ModuleRoot $ModuleRoot
'@
}