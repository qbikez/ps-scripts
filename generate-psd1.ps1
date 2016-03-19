[cmdletbinding()]
param ($path = ".", $author, $description, $company)

function generate-modulemanifest($path, $author, $description, $company) {
	$projecturl = (git remote -v)[0].split(@("`t"," "))[1]
	$rootmodule = get-childitem $path -filter "*.psm1"
	$psd1 = $rootmodule.FullName -replace "\.psm1",".psd1"

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