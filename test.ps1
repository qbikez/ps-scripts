param ($path = ".", [switch][bool]$EnableExit = $false, [switch][bool]$coverage, $outputFormat = "NUnitXml")

#$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::User)

Import-Module pester 

$artifacts = "$path\artifacts"

if (!(Test-Path $artifacts)) { $null = New-Item -type directory $artifacts }

Write-Host "running tests. artifacts dir = $((gi $artifacts).FullName)"

if (!(Test-Path $artifacts)) {
    $null = New-Item $artifacts -ItemType directory
}

$codeCoverage = @(Get-ChildItem "$path\src" -Filter "*.ps1" -Recurse) | % { $_.FullName }

Write-Host "testing code coverage of files:"
$codeCoverage | % { Write-Host $_ }

$a = @()
if ($coverage) {
    $a += @("-CodeCoverage", $codeCoverage)
}

Write-Host "running pester tests in $path\test"

$r = Invoke-Pester "$path\test" -OutputFile "$artifacts\test-result.xml" -OutputFormat:$outputFormat -EnableExit:$EnableExit $a

Write-Host "pester result = '$r' lastexitcode=$lastexitcode"

return $r
