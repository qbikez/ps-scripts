[CmdletBinding()]
param ($path = ".")

. $psscriptroot\imports\get-envinfo.ps1

$e = get-envinfo -checkcommands "Install-Module"
$e

write-host "PSVersions:"
$PSVersionTable

if ($e.commands["Install-Module"] -eq $null) {
    . $psscriptroot\imports\download-oneget.ps1

    download-oneget
    $e = get-envinfo -checkcommands "Install-Module"

    $e

    get-module packagemanagement -ListAvailable   
}

Get-PSRepository

try {
    write-host "installing nuget package provider"
# this isn't availalbe in the current official release of oneget (?)
install-packageprovider -Name NuGet -Force -MinimumVersion 2.8.5.201 -verbose
}
catch {
 #ignore   
}
# this is a private function
#Install-NuGetClientBinaries -force -CallerPSCmdlet $PSCmdlet
#Install-NuGetClientBinaries -confirm:$false

Set-PSRepository -name PSGallery -InstallationPolicy Trusted -verbose 
