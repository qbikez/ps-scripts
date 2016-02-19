param ($path = ".")

import-module pester 

$artifacts = "$path\artifacts"

write-host "running tests. artifacts dir = $((gi $artifacts).FullName)"

if (!(Test-Path $artifacts)) {
    $null = new-item $artifacts -ItemType directory
}
$r = Invoke-Pester "$path\test" -OutputFile "$artifacts\test-result.xml" -OutputFormat NUnitXml -EnableExit

return $r
