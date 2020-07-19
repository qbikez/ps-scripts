function get-msbuildPath {
    [CmdletBinding()]
    param($version = $null)
  
    try {
        $regversions = (gci HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions) | % { 
            return [PSCustomObject]@{
                Path    = (Get-ItemProperty -path "hklm:/$($_.Name)" -Name MSBuildToolsPath).MSBuildToolsPath
                Name    = $_.Name
                Version = ($_.Name | split-path -Leaf | % { 
                        [double]::Parse($_, [System.Globalization.CultureInfo]::InvariantCulture) 
                    })
            }
        } | sort -Descending Version
        $vswhereversions = @()
        $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

        if (test-path $vswhere) {
            $vswhereversions = & $vswhere -latest -prerelease -products * -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" `
            | % { 
                return [PSCustomObject]@{ 
                    Path = split-path -parent $_
                }
            }
        }

        $versions = @($vswhereversions) + @($regversions)

        if ($version -ne $null) {
            $ver = $versions | ? { $_.Version -eq $version }
        }
        
        else {
            $ver = $versions | select -First 1
        }
        
        $path = $ver.Path  
        write-verbose "found msbuild version $($ver.Name) at '$path'"
        return Join-Path $path "msbuild.exe"
    }   
    catch {
        return $null
    }
}

function add-msbuildPath() {
    if (!(get-command "msbuild" -ErrorAction Ignore)) { 
        Write-Warning "'msbuild.exe' not found on PATH" 
        try {
            $path = get-msbuildPath
            $path = split-path -Parent $path
            $env:Path = "$env:Path;$path"
        }   
        catch {
            Write-Warning $_
        }
    }
}