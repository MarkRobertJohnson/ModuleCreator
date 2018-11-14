function New-AzureDevOpsProject {
  param(
    [string]$PersonalAccessToken,
    [string]$Organization,
    [string]$ProjectName,
    [string]$ProjectDescription
  )
  $body = @"
{
  "name": "$ProjectName",
  "description": "$ProjectDescription",
  "capabilities": {
    "versioncontrol": {
      "sourceControlType": "Git"
    },
    "processTemplate": {
      "templateTypeId": "6b724908-ef14-45cf-84f8-768b5384da45"
    }
  }
}
"@

  $headers = Get-AzureDevOpsAuthHeader -PersonalAccessToken $PersonalAccessToken
  [System.Net.ServicePointManager]::Expect100Continue = $true
  [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-RestMethod -Method POST https://dev.azure.com/$Organization/_apis/projects?api-version=4.1 -Body $body -Headers $headers -ContentType application/json
}