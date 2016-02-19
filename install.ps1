[CmdletBinding(SupportsShouldProcess=$true)]
param($srcDir = $null, [switch][bool] $importonly) 

function install-modulelink {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([Parameter(mandatory=$true)][string]$modulename) 
    
    
    $target = $modulename
    if ($target.EndsWith(".psm1")) {
        $target = split-path -parent ((get-item $target).FullName)    
    }
    $target = (get-item $target).FullName
    
    $modulename = split-path -leaf $target
    $path = "C:\Program Files\WindowsPowershell\Modules\$modulename"
    if (test-path $path) {
        if ($PSCmdlet.ShouldProcess("removing path $path")) {
            # packagemanagement module may be locking some files in existing module dir
            if (gmo powershellget) { rmo powershellget }
            if (gmo packagemanagement) { rmo packagemanagement }
            remove-item -Recurse $path -force
            # in case of mklink junction, first we remove junction, then we have to remove remaining empty dir
            if (test-path $path) { remove-item -Recurse $path }
        }
    }
    write-host "executing mklink /J $path $target"
    cmd /C "mklink /J ""$path"" ""$target"""
}

if (!$importonly) {
    if ($srcDir -eq $null) {
        $srcDir = "$psscriptroot\..\.."
    }

    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin=$prp.IsInRole($adm)
    
    if ($IsAdmin) {    
        $root = $psscriptroot
        $modules = get-childitem "$srcDir" -filter "*.psm1" -recurse | % { $_.Directory.FullName }
        $modules | % { install-modulelink $_ }
    } else {
        Invoke-Elevated $psscriptroot\install.ps1 @PSBoundParameters
    }
    
     
}
