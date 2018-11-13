param([Parameter(mandatory=$true)][string]$ModuleRoot)

<#
        .SYNOPSIS
        Auto loads all functions.  Requires that functions have a 1 to 1 mapping to files.

        ********************************************************************
        NOTE: This is boiler plate code that can be copied to any new module
        ********************************************************************
#>
$moduleName = [io.path]::GetFileNameWithoutExtension((gci $moduleRoot | where { $_.name -like '*.psm1' -or $_.name -like '*.psd1' } | select -First 1).FullName)
$functionNamesToExport = @()
#All *.ps1 files in these folders will be included in the module
$functionPaths = @("$ModuleRoot\Public\*.ps1", "$ModuleRoot\Private\*\*.ps1")
$excludeFunctionPaths = @('*.Tests.ps1','*.Test.ps1')

foreach($functionPath in $functionPaths) {
    # load all functions from files in the "Functions" folder, by convention, only functions matching file names are exported
    Gci $functionPath -exclude $excludeFunctionPaths -recurse -force  |
        % { 
            Write-Debug "Importing functions from '$($_.FullName)'"
            . $_.FullName;
            $functionName = [io.path]::GetFileNameWithoutExtension($_.FullName)
            #Only export the function if the name matches
            
            if(gci function: | ? { $_.Name -like $functionName -and $_.ModuleName -like $moduleName}) {
                $functionNamesToExport += $functionName
            } else {
                write-verbose "A function for module '$moduleName' with the name '$functionName' was expected to exist the file '$($_.FullName)' but was not found"
            }
        }
}

return $functionNamesToExport