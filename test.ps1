param ($path = ".")

import-module pester 

$artifacts = "$path\artifacts"
if (!(Test-Path $artifacts)) {
    $null = new-item $artifacts -ItemType directory
}
$r = Invoke-Pester "$path\test" -OutputFile "$artifacts\test-result.xml" -OutputFormat NUnitXml -EnableExit

return $r
