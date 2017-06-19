function download-oneget() {
    $url = "https://download.microsoft.com/download/4/1/A/41A369FA-AA36-4EE9-845B-20BCC1691FC5/PackageManagement_x64.msi"

    $tmpdir = "temp"
    if (!(test-path $tmpdir)) {
        $null = new-item -type Directory $tmpdir
    }

    $dest = "$tmpdir\PackageManagement_x64.msi"
    $log = "$tmpdir\log.txt"
    if (!(test-path $dest)) {
        write-host "downloading $dest"
        Invoke-WebRequest -Uri $url -OutFile $dest
    }
    write-host "installing $dest"
    $null = & cmd /c start /wait msiexec /i $dest /qn /passive /log "$log"
    
    write-host "## log: ##"
    Get-Content $log | write-host
    write-host "## log end ##"
    fix-oneget
}

function fix-oneget() {
    if ($PSVersionTable.PSVersion.Major -lt 5 -or $true) {
        $psgetmodules = @(get-module powershellget -ListAvailable)
        write-host "psget modules:"
        $psgetmodules
        $modulesrc = $psgetmodules[0].path
        $moduleDir = (split-path -parent $modulesrc)          
        $target = join-path (split-path -parent $modulesrc) "PSGet.psm1"
        $src = "https://gist.githubusercontent.com/qbikez/d6fc3151f9702ea1aab6/raw/PSGet.psm1"
        $tmp = "$tmpdir\PSGet.psm1"
        write-host "downloading patched Psget.psm1 from $src to $tmp"
        Invoke-WebRequest $src -OutFile $tmp
        write-host "overwriting $target with $tmp"
        Copy-Item $tmp $target -Force -Verbose
        
        $target = join-path (split-path -parent $modulesrc) "PowerShellGet.psd1"
        $src = "https://gist.githubusercontent.com/qbikez/d6fc3151f9702ea1aab6/raw/PowerShellGet.psd1"
        $tmp = "$tmpdir\PowerShellGet.psd1"
        write-host "downloading patched Psget.psd1 from $src to $tmp"
        Invoke-WebRequest $src -OutFile $tmp
        write-host "overwriting $target with $tmp"
        Copy-Item $tmp $target -Force -Verbose
        
        write-host "files in $moduleDir :"
        Get-ChildItem $moduleDir -Recurse
        
        # check if it works
        
        if (get-module powershellget) { remove-module powershellget }        
        
        write-host "available powershellget modules:"
        get-module powershellget -ListAvailable
        
        import-module powershellget -ErrorAction Stop -MinimumVersion 1.0.0.1
    }
}
