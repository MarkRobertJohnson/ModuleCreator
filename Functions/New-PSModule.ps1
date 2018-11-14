function New-PSModule {
  param(
    [Parameter(Mandatory)]
    [string]$ModuleName,
    [parameter(Mandatory, HelpMessage='Enter the tags comma separated (i.e. tag1,tag2,tag3')]
    [string]$Tags,
    [parameter(Mandatory, HelpMessage='Module description')]
    [string]$Description,
    [switch]$Force,
    [array]$Extension = ('.pstemplate','.psm1','.psd1','.txt'),
    [Version]$TemplatizerVersion = '1.0.20',
    [String]$ConfigPath,
    [String]$Source = ([io.path]::Combine($PSScriptRoot,'..','MODULE_TEMPLATE')),
    [String]$Destination = (Join-Path (Get-Location) $ModuleName),
    [parameter(Mandatory, HelpMessage='Company Name')]
    [String]$CompanyName,
    [parameter(Mandatory, HelpMessage='Author')]
    [String]$Author,
    [parameter(Mandatory, HelpMessage='Source Control user name')]
    [string]$ScmUsername,
    [string]$ScmBranch = 'master',
    [string]$ProjectUri = "https://www.github.com/$ScmUsername/$ModuleName",
    [string]$IconUri = "https://raw.githubusercontent.com/$ScmUsername/$ModuleName/$ScmBranch/gallery-icon-100x100.png",
    [string]$LicenseUri = "https://raw.githubusercontent.com/$ScmUsername/$ModuleName/$ScmBranch/LICENSE",
    [ValidateSet('GitHub')]
    [string]$ScmType = 'GitHub',
    [parameter(Mandatory, HelpMessage='NugetApiKey for publishing to PowerShell gallery')]
    [string]$NugetApiKey,
    [string]$AzureDevopsPersonalAccessToken,
    [switch]$CreateRepository,
    [switch]$PublishModule,
    [switch]$CreateAzureDevopsPipeline,
    [string]$AzureDevopsOrg

  )
  <#
        .SYNOPSIS
        Creates a new module from a template module 'MODULE_TEMPLATE'
  #>

    $null = Get-PSRepository -ErrorAction SilentlyContinue

    $pst = Get-Module PSTemplatizer  -ListAvailable | Where { $_.Version -gt $TemplatizerVersion }
    
    if(-not $pst) {
        Install-Module PSTemplatizer -RequiredVersion $TemplatizerVersion -Force
    }
    Import-Module PSTemplatizer -Verbose -RequiredVersion $TemplatizerVersion

    $params = @{
        RegExDynamicReplacements = @{
            "MODULE_TEMPLATE" = '$TemplateModuleName';
        };
        Author = "$Author";
        CompanyName = "$CompanyName";
        Copyright = '[[[DateTime]::Now.Year]] [[$CompanyName]]';
        IconUri = $IconUri;
        LicenseUri = $LicenseUri;
        ModuleGuid = '[[[guid]::NewGuid().ToString()]]';
        TemplateModuleName = $ModuleName;
        ProjectUri = $ProjectUri;
        Tags = ($Tags -split ',' | % { "'" + $_.Trim(@("'",'"')) + "'"}) -join ',';
        Description = $Description
    }

    if(-not $ConfigPath) {
        #Convention based location of parameters
        $ConfigPath = Join-Path $Source "template_parameters.json"
        if(!(Test-Path $ConfigPath -ErrorAction SilentlyContinue)) {
            Convert-HashTableToObject $params | ConvertTo-Json | Out-File -Encoding utf8 $ConfigPath 
        }
    }
    

    Import-TemplateConfiguration -Path $configPath -Verbose

    if(Test-Path $Destination) {
        if($Force) {
            del $Destination -force -Recurse
        } else {
            throw "The destination module path '$Destination' already exists"
        }
    } 
    copy $Source $Destination -Recurse -Force

    #Perform any token replacements in directory names
    Expand-TemplatesInDirectoryNames -SearchDirectory $Destination 

    #Perform token replacments in files
    Expand-TemplateFileContent -SearchDirectory $Destination -Extension $Extension 

    #Perform synamic regex replacements
    Expand-TemplateFileContent -SearchDirectory $Destination  -Extension $Extension `
                                 -Transform {
                                                param([Parameter(ValueFromPipeline=$true)][string]$Text, [string]$Path, [string]$Destination, [ref]$TotalExpansions)                                                                          
                                                Replace-RegExDynamicContent -Replacements $params.RegExDynamicReplacements @PSBoundParameters
                                            }
    if($ScmType -eq 'GitHub' -and $CreateRepository) {
        Install-Module GitHelperUtil -force
        Import-Module GitHelperUtil -force
        Install-GitCommandLine

        New-GitHubRepository -Name $ModuleName -Username $ScmUsername
        
        Invoke-GitCommand 'init .' -RepoDir $Destination
        Invoke-GitCommand 'add .' -RepoDir $Destination
        Invoke-GitCommand "commit -m `"Initial Commit of $ModuleName`"" -RepoDir $Destination
        Invoke-GitCommand "remote add origin $ProjectUri" -RepoDir $Destination
        Invoke-GitCommand 'remote -v' -RepoDir $Destination
        Invoke-GitCommand "push origin $ScmBranch" -RepoDir $Destination
    }
	
    if($NugetApiKey -and $PublishModule) {
      Publish-Module -Path $Destination -Force -NuGetApiKey $NugetApiKey
    }
	
    #Now setup Azure DevOps
    if($CreateAzureDevopsPipeline -and $AzureDevopsPersonalAccessToken) {
      New-AzureDevopsProject -PersonalAccessToken $AzureDevopsPersonalAccessToken -Organization $AzureDevopsOrg -ProjectName $moduleName -ProjectDescription $Description
    }

}
