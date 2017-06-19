[cmdletbinding()]
param ($path = ".", $author, $description, $company)

function generate-modulemanifest($path, $author, $description, $company) {
	$projecturl = (git remote -v)[0].split(@("`t"," "))[1]
	$rootmodule = get-childitem $path -filter "*.psm1"
	$psd1 = $rootmodule.FullName -replace "\.psm1",".psd1"
	if ($null -eq $description) {
		$description = "$($rootmodule.Name -replace '.psm1','') Module" 
	}

	Write-Verbose "generating manifest '$(split-path -leaf $psd1)' for module '$rootmodule'"
	new-modulemanifest -Verbose `
		-path $psd1 `
		-rootmodule $rootmodule `
		-projecturi $projecturl `
		-moduleversion 1.0.0 `
		-Author $author `
		-Description $description `
		-CompanyName $company
}

$psms = Get-ChildItem $path -Filter "*.psm1" -Recurse
$psms | % {
	pushd 
	try {
		cd (split-path -Parent $_.FullName)
		generate-modulemanifest "." -author $author -description $description -company $company
	}
	finally {
		popd
	}
}