param ($path = ".", [switch][bool]$EnableExit = $false)

#$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::User)

import-module pester 

$artifacts = "$path\artifacts"

if (!(test-path $artifacts)) { $null = new-item -type directory $artifacts }

write-host "running tests. artifacts dir = $((gi $artifacts).FullName)"

if (!(Test-Path $artifacts)) {
    $null = new-item $artifacts -ItemType directory
}

$codeCoverage = @(Get-ChildItem "$path\src" -Filter "*.ps1" -Recurse) | % { $_.FullName }

Write-Host "testing code coverage of files:"
$codeCoverage | % { write-host $_ }

$r = Invoke-Pester "$path\test" -OutputFile "$artifacts\test-result.xml" -OutputFormat NUnitXml -EnableExit:$EnableExit -CodeCoverage $codeCoverage

return $r
