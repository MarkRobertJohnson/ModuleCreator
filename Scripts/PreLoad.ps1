param([Parameter(mandatory=$true)][string]$ModuleRoot)

remove-item -path alias:wtc -Force -ErrorAction SilentlyContinue

New-Alias -Name wtc -Value Start-WebTryCatch -Force -Description 'Web try-catch, re-throws including more detail from web werver response'
Set-Alias -Name wtc -Value Start-WebTryCatch -Force -Description 'Web try-catch, re-throws including more detail from web werver response'