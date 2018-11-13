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
    [String]$Destination = (Join-Path (Get-Location) $ModuleName)
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
        Author = "Axian, Inc.";
        CompanyName = "Axian, Inc.";
        Copyright = '© [[[DateTime]::Now.Year]] [[$CompanyName]]';
        IconUri = '';
        LicenseUri = "http://LICENSE_URI";
        ModuleGuid = '[[[guid]::NewGuid().ToString()]]';
        TemplateModuleName = $ModuleName;
        ProjectUri = 'http://PROJECT_URI';
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
}
