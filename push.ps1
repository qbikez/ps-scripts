[CmdletBinding(SupportsShouldProcess=$true)]
param($path = ".", [switch][bool]$newversion, $version, [switch][bool]$newbuild, $buildno, $source, $apikey)

function push-module {
[CmdletBinding(SupportsShouldProcess=$true)]
param($modulepath, [switch][bool]$newversion, [switch][bool]$newbuild, $version, $buildno, $source, $apikey)
	write-verbose "publishing module from dir $modulepath"
	    
    $nugeturl = "https://dist.nuget.org/win-x86-commandline/v2.8.6/nuget.exe"
    if (!(test-path "$psscriptroot/.tools/nuget.exe")) {
        if (!(test-path "$psscriptroot/.tools")) { $null = mkdir "$psscriptroot/.tools" }
        # use nuget2, because nuget3 can cause errors when pushing modules (nuget.exe : '' is not a valid version string. At C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1\PSModule.psm1:6784 char:19)
        invoke-webrequest $nugeturl -OutFile "$psscriptroot/.tools/nuget.exe"
    }
    $_path = $env:path
    try {
        Import-Module pathutils
        write-host "adding '$psscriptroot\.tools' to PATH"
        Add-ToPath "$psscriptroot\.tools" -first
        write-host "PATH: $env:path"
        $nuget = (get-command "nuget.exe").Source
        write-host "using nuget at '$nuget'" 

        if ($null -ne $source) {
            $repo = $source
        } 
        else {
            $repo = "$env:PS_PUBLISH_REPO"
        }
        if ([string]::IsNullOrEmpty($repo)) {
            $repo = "PSGallery"
        }

        if ([string]::IsNullOrEmpty($repo)) {
            throw "no repository given and no PS_PUBLISH_REPO env variable set"
        }

        if ($null -ne $apikey) {
            $key = $apikey
        } else {
            $key = "$env:PS_PUBLISH_REPO_KEY"
        }
        if ([string]::IsNullOrEmpty($key)) {
            try {
                Import-Module cache -ErrorAction stop
                $key = get-passwordcached $repo
            } catch {
                write-error "'cache' module is not available" -ErrorAction ignore
            }
        }
        if ([string]::IsNullOrEmpty($key)) {
            try {
                Import-Module oneliners -ErrorAction stop
                $settings = import-settings
                $seckey = $settings["$repo.apikey"]
                if ($null -ne $seckey) { $key = convertto-plaintext $seckey }
            } catch {
                 write-error "'oneliners' module is not available" -ErrorAction ignore
            }
        }

        if ([string]::IsNullOrEmpty($key)) {
            throw "no apikey given, no PS_PUBLISH_REPO_KEY env variable set and no cached password for repo '$repo' found"
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
        if ($null -ne $version) {
            $newver = $version
        }
    
        if ($null -ne $buildno -or $newbuild) { 
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
    finally {
        $env:path = $_path
    }
}

$envscript = "$path\.env.ps1" 
if (test-path "$envscript") {
    . $envscript
}

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
