[CmdletBinding(SupportsShouldProcess=$true)]
param($path = ".", [switch][bool]$newversion, $version, [switch][bool]$newbuild, $buildno, $source, $apikey)

function push-module {
[CmdletBinding(SupportsShouldProcess=$true)]
param($modulepath, [switch][bool]$newversion, [switch][bool]$newbuild, $version, $buildno, $source, $apikey)
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
        $newver = Increment-Version $ver
    } else {
        $newver = $ver
    }
    if ($version -ne $null) {
        $newver = $version
    }
    
    if ($buildno -ne $null -or $newbuild) { 
        $splits = $newver.split(".")
        $lastbuild = 0
        if ($splits.length -gt 3) {
            $newver = [string]::Join(".", ($splits | select -First 3))
            $lastbuild = [int]::Parse($splits[3])            
        }        
        if ($newbuild) { $buildno = $lastbuild + 1 }
        $newver += ".$buildno"
     }

    write-verbose "new module version: $newver"
    set-moduleversion $modulepath -version $newver

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

foreach($_ in $modules) { 
    push-module $_ -newversion:$newversion -version $version -newbuild:$newbuild -buildno $buildno -source $source -apikey $apikey -ErrorAction Stop
    if ($env:APPVEYOR_API_URL -ne $null)  {
        Add-AppveyorMessage -Message "Module $_ v $version build $Buildno published to $source" -Category Information 
    }
}
