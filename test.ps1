param ($path = ".", [switch][bool]$EnableExit = $false, [switch][bool]$coverage, $outputFormat = "NUnitXml")

#$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::User)

$artifacts = "$path\artifacts"

if (!(Test-Path $artifacts)) { $null = New-Item -type directory $artifacts }

Write-Host "running tests. artifacts dir = $((gi $artifacts).FullName)"

if (!(Test-Path $artifacts)) {
    $null = New-Item $artifacts -ItemType directory
}

$codeCoverage = $null

if ($coverage) {
    $codeCoverage = @(Get-ChildItem "$path\src" -Filter "*.ps1" -Recurse) | % { $_.FullName }

    Write-Host "testing code coverage of files:"
    $codeCoverage | % { Write-Host $_ }
}

Write-Host "Importing Pester Module"

ipmo Pester -Verbose:$true -ErrorAction Stop -MinimumVersion 6.0.0
$pester = Get-Module Pester
$pester | Format-List | Out-Host

$config = New-PesterConfiguration
$config.Run.Path = "$path\test"
$config.Run.Exit = $EnableExit ? $true : $false
$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = "$artifacts\test-result.xml"
$config.TestResult.OutputFormat = $outputFormat
$config.CodeCoverage.Enabled = $coverage ? $true : $false
$config.CodeCoverage.Path = $codeCoverage

$config | Format-List | Out-Host
Write-Host "running pester tests in $path\test."

Invoke-Pester -Configuration $config

Write-Host "pester result = '$r' lastexitcode=$lastexitcode"

return $r
