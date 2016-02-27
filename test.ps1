param ($path = ".")

#$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::User)

import-module pester 

$artifacts = "$path\artifacts"

if (!(test-path $artifacts)) { $null = new-item -type directory $artifacts }

write-host "running tests. artifacts dir = $((gi $artifacts).FullName)"

if (!(Test-Path $artifacts)) {
    $null = new-item $artifacts -ItemType directory
}
$r = Invoke-Pester "$path\test" -OutputFile "$artifacts\test-result.xml" -OutputFormat NUnitXml -EnableExit

return $r
