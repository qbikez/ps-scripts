[CmdletBinding(SupportsShouldProcess=$true)]
param($path = ".", [switch][bool]$newversion)


function push-module {
[CmdletBinding(SupportsShouldProcess=$true)]
param($modulepath, [switch][bool]$newversion)

    $repo = "$env:PS_PUBLISH_REPO"
    $key = "$env:PS_PUBLISH_REPO_KEY"

    . $psscriptroot\imports\set-moduleversion.ps1
    . $psscriptroot\imports\nuspec-tools.ps1

    $ver = get-moduleversion $modulepath
    if ($newversion) {
        $newver = Incremet-Version $ver
    } else {
        $newver = $ver
    }
    set-moduleversion $modulepath -version $newver

    import-module PowerShellGet
    import-module PackageManagement
    
    if (!(Get-PSRepository $repo -ErrorAction Continue)) {
        write-host "registering PSRepository $repo"
        Register-PSRepository -Name $repo -SourceLocation $repo/nuget -PublishLocation $repo -InstallationPolicy Trusted -Verbose
    } 
    write-host "publishing module $modulepath v$newver to repo $repo"
    Publish-Module -Path $modulepath -Repository $repo  -NuGetApiKey $key -Verbose

}

$envscript = "$path\.env.ps1" 
if (test-path "$envscript") {
    . $envscript
}

  

$root = $psscriptroot
$modules = get-childitem "$path\src" -filter "*.psm1" -recurse | % { $_.Directory.FullName }
$modules | % { push-module $_ -newversion:$newversion }
