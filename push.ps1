[CmdletBinding(SupportsShouldProcess=$true)]
param($path, [switch][bool]$newversion)


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
    
    if (!Get-PSRepository $repo) {
        Register-PSRepository -Name $repo -SourceLocation $repo/nuget -PublishLocation $repo -InstallationPolicy Trusted
    } 
    
    Publish-Module -Path $modulepath -Repository $repo -Verbose -NuGetApiKey $key

}

$envscript = "$path\.env.ps1" 
if (test-path "$envscript") {
    . $envscript
}

  

$root = $psscriptroot
$modules = get-childitem "$path\src" -filter "*.psm1" -recurse | % { $_.Directory.FullName }
$modules | % { push-module $_ -newversion:$newversion }
