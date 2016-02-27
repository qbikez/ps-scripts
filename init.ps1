[CmdletBinding()]
param ($path = ".")

. $psscriptroot\imports\get-envinfo.ps1

$e = get-envinfo -checkcommands "Install-Module"
$e

if ($e.commands["Install-Module"] -eq $null) {
    . $psscriptroot\imports\download-oneget.ps1

    download-oneget
    $e = get-envinfo -checkcommands "Install-Module"

    $e

    get-module packagemanagement -ListAvailable   
}

Get-PSRepository


# this isn't availalbe in the current official release of oneget 
#install-packageprovider -Name NuGet -Force -MinimumVersion 2.8.5.201 -verbose

# this is a private function
#Install-NuGetClientBinaries -force -CallerPSCmdlet $PSCmdlet
#Install-NuGetClientBinaries -confirm:$false

Set-PSRepository -name PSGallery -InstallationPolicy Trusted -verbose 
