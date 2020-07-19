[CmdletBinding()]
param($path = ".", $pesterVersion = $null)

if (test-path "$path\.git") {
     write-host "restoring git submodules"
     git submodule update --init --recursive 2>&1 | % { $_.ToString() }
}

write-host "Installing 'require' module"

install-module require 
import-module require

req pathutils


write-host  "installing 'Pester' module"

if ($pesterfromsource) {
	pushd
	git clone http://github.com/pester/pester third-party/pester 2>&1 | % { $_.ToString() }  
	cd third-party/pester
	git checkout 676818ac11bc7c2d2772416b5ad68cb1caa89d57 2>&1 | % { $_.ToString() }

	$pesterPath = (get-item "third-party/pester").FullName

	write-host "adding pester ($pesterPath) to PSModulePath"
	$env:PSModulePath = "$pesterPath;$($env:PSModulePath)"
	[System.Environment]::SetEnvironmentVariable("PSModulePath", $env:PSModulePath, [System.EnvironmentVariableTarget]::User);    


	popd
} else {
	# req pester -version $pesterVersion -scope CurrentUser
	$a = @()
	if ($pesterVersion) {
		$a += "-MinimumVersion",$pesterVersion
	}
	Install-Module pester -Scope CurrentUser -Force @a
}

