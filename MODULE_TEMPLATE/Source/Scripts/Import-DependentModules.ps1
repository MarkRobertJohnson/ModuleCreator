param([Parameter(mandatory=$true)][string]$ModuleRoot)

function Get-LatestInstalledModule {
    param([string]$Name)
    Get-Module -Name $Name -ListAvailable | sort -Property Version -Descending | Select-object -First 1
}

$module = Get-Module -FullyQualifiedName $ModuleRoot -ListAvailable -ErrorAction SilentlyContinue
if($module -and $module.PrivateData -and $module.PrivateData.PSData -and $module.PrivateData.PSData.ExternalModuleDependencies) {
    $module.PrivateData.PSData.ExternalModuleDependencies | foreach {
        $depModule = Get-LatestInstalledModule $_
        if(-not $depModule) {
            Write-Host "Module dependency '$($_)' was not installed, will attempt to install from default PS Repository ..."
            try {
                #& "$ModuleRoot\Scripts\Set-DefaultPSGalleryUrl.ps1" -RemoveAllOtherRepositories -RepoUrl ''
                Install-Module -Name $_ -Force 
                $depModule = Get-LatestInstalledModule $_           
            } catch {
                Write-Warning $_
            }

        }
        
        Write-Host "Importing dependent module '$($_)' ..."
        try {
            $depModule | Import-Module -Force  -Scope Global
        } catch {
            Write-Warning $_
        }
    }
}