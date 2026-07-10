param ($path = ".")

function ExitWithCode { 
    param 
    ( 
        $exitcode 
    )

    $host.SetShouldExit($exitcode) 
    exit 
}

$artifacts = "$path\artifacts"

try {
    if (!(Test-Path $artifacts)) { $null = New-Item -type directory $artifacts }
    if (Test-Path "$artifacts\test-result.xml") {
        Remove-Item "$artifacts\test-result.xml"
    }

    Write-Host "running appveyor test script. artifacts dir = $((gi $artifacts).FullName)"

    $testResultCode = & "$PSScriptRoot\test.ps1" (gi $path).FullName -EnableExit

    if (!(Test-Path "$artifacts\test-result.xml")) {
        throw "test results not found at $artifacts\test-result.xml!"
    }

    if (!(Test-Path "$artifacts\test-result.xml")) {
        throw "test artifacts not found at '$artifacts\test-result.xml'!"
    }
    
    $resultpath = (Get-Item "$artifacts\test-result.xml").FullName
    $content = Get-Content "$artifacts\test-result.xml" | Out-String
    if ([string]::isnullorwhitespace($content)) {
        throw "$artifacts\test-result.xml is empty!"
    }
    else {
        $content
    }

    $url = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    #$url = https://ci.appveyor.com/api/testresults/nunit/bq558ckwevwb47qb
    # upload results to AppVeyor
    Write-Host "uploading test result from $resultpath to $url"
    $wc = New-Object 'System.Net.WebClient'

    try {
        $r = $wc.UploadFile($url, $resultpath)
    
        Write-Host "upload done. result = $r"
    } 
    finally {
        $wc.Dispose()
    }
    Write-Host "pester result = '$testResultCode' lastexitcode=$lastexitcode"

    #ExitWithCode $testResultCode

}
catch {
    ExitWithCode 1  
}
