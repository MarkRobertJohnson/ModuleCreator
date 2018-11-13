param(
    [CmdletBinding()]
    [Parameter(Mandatory)][string]$RepoUrl,
        [switch]$RemoveAllOtherRepositories)

function Invoke-PSRepositoryBootstrap {
    [CmdletBinding()]
    param([string]$RepoUrl,
        [switch]$RemoveAllOtherRepositories)
        
    if($RemoveAllOtherRepositories) {
        Remove-AllNonDefaultPSRepositories
    }
            
    if($source = Get-PackageSource -Location $repoUrl -ProviderName PowerShellGet -ErrorAction SilentlyContinue ) {
        if($source.Name -like 'PSGallery') {
            Write-verbose "The default PSGallery already has the expected URL of $repoUrl"
            return
        }
    }    
    
    try {
        if(-not $source) {
            $source = Register-PackageSource -Name TempSource -Trusted -Location $repoUrl -ProviderName PowerShellGet
        }

        $null = Install-Package -Name PowerShellUtil -ProviderName PowerShellGet -Source $repoUrl -Force -MinimumVersion 1.0.1 -ForceBootstrap
        Import-Module PowerShellUtil -force
        Set-PSGalleryToPointToCustomUrl -Url $RepoUrl -RemoveAllOtherRepositories:$RemoveAllOtherRepositories
    } finally {

        try { Unregister-PackageSource -InputObject $source } catch {Write-Warning $_}
        try { Get-Module PowerShellUtil | Remove-Module -Force } catch { write-warning $_}
    }
}

function Set-PSGalleryToPointToCustomUrl {
    [CmdletBinding()]
    param([string]$Url )

    Set-PSRepositoryConfig -RepositoryName PSGallery -SourceLocation $Url `
                           -PublishLocation $Url `
                           -ScriptSourceLocation '' `
                           -ScriptPublishLocation '' `
                           -Trusted $true `
                           -InstallationPolicy Trusted
    #This forces a reload of the config file in the curren PowerShell session
    try {
        Set-PSRepository -Name PSGallery
    } catch {}

    try {
        Get-PSRepository
    } catch {Write-Warning $_}

}


Invoke-PSRepositoryBootstrap -RepoUrl $repoUrl -RemoveAllOtherRepositories:$RemoveAllOtherRepositories