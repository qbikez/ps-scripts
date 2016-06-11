[CmdletBinding(SupportsShouldProcess=$true)]
param($path = ".", [switch][bool]$newversion, $version, $buildno, $source, $apikey)


function push-module {
[CmdletBinding(SupportsShouldProcess=$true)]
param($modulepath, [switch][bool]$newversion, $version, $buildno, $source, $apikey)
	write-verbose "publishing module from dir $modulepath"
	
    if ($source -ne $null) {
        $repo = $source
    } 
    else {
        $repo = "$env:PS_PUBLISH_REPO"
    }
    if ($apikey -ne $null) {
        $key = $apikey
    } else {
        $key = "$env:PS_PUBLISH_REPO_KEY"
    }
    . $psscriptroot\imports\set-moduleversion.ps1
    . $psscriptroot\imports\nuspec-tools.ps1

    $ver = get-moduleversion $modulepath
    write-verbose "detected module version: $ver"
    if ($newversion) {
        $newver = Incremet-Version $ver
    } else {
        $newver = $ver
    }
    if ($version -ne $null) {
        $newver = $version
    }
    
    write-verbose "new module version: $newver"
    set-moduleversion $modulepath -version $newver

    if ($buildno -ne $null) { $newver += ".$buildno" }
    write-verbose "publishing module version: $newver"

    import-module PowerShellGet
    import-module PackageManagement
    
    if (!(Get-PSRepository $repo -ErrorAction Continue)) {
        write-host "registering PSRepository $repo"
        Register-PSRepository -Name $repo -SourceLocation $repo/nuget -PublishLocation $repo -InstallationPolicy Trusted -Verbose
    }
    $repourl = & git remote get-url origin 
    write-host "publishing module $modulepath v$newver to repo $repo. projecturi=$repourl"
    
    if ($pscmdlet.ShouldProcess("publishing module $modulepath v$newver to repo $repo")) {
        Publish-Module -Path $modulepath -Repository $repo -NuGetApiKey $key -Verbose
    }
}

$envscript = "$path\.env.ps1" 
if (test-path "$envscript") {
    . $envscript
}

$root = $psscriptroot

if (test-path $path\src) {
	$path = "$path\src"
} 

write-verbose "looking for modules in $((gi $path).fullname)"

$modules = @(get-childitem "$path" -filter "*.psm1" -recurse | % { $_.Directory.FullName })

write-verbose "found $($modules.length) modules: $modules"

$modules | % { push-module $_ -newversion:$newversion -version $version -buildno $buildno -source $source -apikey $apikey }
