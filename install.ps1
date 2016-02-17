[CmdletBinding(SupportsShouldProcess=$true)]
param($srcDir = ".", [switch][bool] $importonly) 

function install-modulelink($modulename) {
    $path = "C:\Program Files\WindowsPowershell\Modules\$modulename"
    $target = "$PSScriptRoot\..\$srcDir\$modulename"
    $target = (get-item $target).FullName

    if (test-path $path) {
        if ($PSCmdlet.ShouldProcess("removing path $path")) {
            remove-item -Recurse $path
        }
    }
    write-host "executing mklink /J $path $target"
    cmd /C "mklink /J ""$path"" ""$target"""
}

if (!$importonly) {
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin=$prp.IsInRole($adm)
    
    if ($IsAdmin) {    
        $root = $psscriptroot
        $modules = get-childitem "$root\..\$srcDir" -filter "*.psm1" -recurse | % { $_.Directory.Name }
        $modules | % { install-modulelink $_ }
    } else {
        Invoke-Elevated .\install.ps1 @PSBoundParameters
    }
    
     
}
