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

install-packageprovider -Name NuGet -Force -MinimumVersion 2.8.5.201 -verbose

#Install-NuGetClientBinaries -force -CallerPSCmdlet $PSCmdlet

Set-PSRepository -name PSGallery -InstallationPolicy Trusted -verbose
