function get-msbuildPath
{
  [CmdletBinding()]
  param($version = $null)
  
  try {
        $versions = (gci HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions) | sort -Descending @{ expression={ 
        $_.Name | split-path -Leaf | % { 
            [double]::Parse($_, [System.Globalization.CultureInfo]::InvariantCulture) 
            }
        }}
        if ($version -ne $null) {
            $ver = $versions | ? {
                 ($_.Name | split-path -Leaf | % { 
            [double]::Parse($_, [System.Globalization.CultureInfo]::InvariantCulture) 
            }) -eq $version
            }
        }
        
        else {
            $ver = $versions | select -First 1
        }
        $path = Get-ItemProperty -path "hklm:/$($ver.Name)" -Name MSBuildToolsPath     
        $path = $path.MSBuildToolsPath  
        write-verbose "found msbuild version $($ver.Name) at $path"
        return Join-Path $path "msbuild.exe"
    }   
    catch {
        return $null
    }
}

function add-msbuildPath() {
if (!(test-command "msbuild")) { 
    Write-Warning "'msbuild.exe' not found on PATH" 
    try {
        $path = get-msbuildPath
        $path = split-path -Parent $path
        $env:Path = "$env:Path;$path"
    }   
    catch {
    }
}
}