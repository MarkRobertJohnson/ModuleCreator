function Get-AzureDevOpsAuthHeader {
  param(
    [string]$PersonalAccessToken
  )

  if(-not $PersonalAccessToken) {
    $securePass = Read-Host -Prompt Password -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
    $PersonalAccessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
  $pair = ":$($PersonalAccessToken)"
  #Encode the string to the RFC2045-MIME variant of Base64, except not limited to 76 char/line.

  $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
  $base64 = [System.Convert]::ToBase64String($bytes)
  #Create the Auth value as the method, a space, and then the encoded pair Method Base64String

  $basicAuthValue = "Basic $base64"
  #Create the header Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==

  $headers = @{ Authorization = $basicAuthValue }
  return $headers
}