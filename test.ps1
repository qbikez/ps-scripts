param ($path = ".", [switch][bool]$EnableExit = $false, [switch][bool]$coverage, $outputFormat = "NUnitXml")

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

$a = @()
if ($coverage) {
    $a += @("-CodeCoverage",$codeCoverage)
}
$r = Invoke-Pester "$path\test" -OutputFile "$artifacts\test-result.xml" -OutputFormat:$outputFormat -EnableExit:$EnableExit $a

return $r
