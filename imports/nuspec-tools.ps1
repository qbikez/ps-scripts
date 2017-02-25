

function Get-NuspecVersion {
    param ($nuspec = $null)
    
	if ([string]::IsNullOrEmpty($nuspec)) {
		$nuspec = Get-ChildItem . -Filter *.nuspec | select -First 1
    }
    $content = Get-Content $nuspec
    $verRegex = "<version>(.*)</version>"
    [string]$line = $content | where { $_ -match $verRegex } | select -First 1
    $ver = $matches[1]
    return $ver
}

function Set-NuspecVersion {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string] $version, $nuspec = $null)
	if ($null -eq $nuspec) {
		$nuspec = Get-ChildItem . -Filter *.nuspec | select -First 1
    }
    $content = Get-Content $nuspec
    $content2 = $content | % { 
        if ($_ -match "<version>(.*)</version>") {       
            $_.Replace( $matches[0], "<version>$version</version>")
        } else {
            $_
        }
    }
    if ($PSCmdlet.ShouldProcess("save '$nuspec' with new version '$version'")) {
        $content2 | Set-Content $nuspec
    }     
}

function Incremet-NuspecVersion($nuspec = $null) {
	if ($null -eq $nuspec) {
		$nuspec = Get-ChildItem . -Filter *.nuspec | select -First 1
    }

    $ver = Get-NuspecVersion $nuspec
    
    $ver2 = Incremet-Version $ver
   
    Set-NuspecVersion -version $ver2 -nuspec $nuspec   
}

if (-not ([System.Management.Automation.PSTypeName]'VersionComponent').Type) {
Add-Type -TypeDefinition @"
   public enum VersionComponent
   {
      Major = 0,
      Minor = 1,
      Patch = 2,
      Build = 3,
      Suffix = 4,
      SuffixBuild = 5
   }
"@
}

function Increment-Version([Parameter(mandatory=$true)]$ver, [VersionComponent]$component = [VersionComponent]::Patch) {
    
    $null = $ver -match "(?<version>[0-9]+(\.[0-9]+)*)(-(?<suffix>.*)){0,1}"
    $version = $matches["version"]
    $suffix = $matches["suffix"]
    
    $vernums = $version.Split(@('.'))
    $lastNumIdx = $component
    if ($component -lt [VersionComponent]::Suffix) {
        $lastNum = [int]::Parse($vernums[$lastNumIdx])
        
        <# for($i = $vernums.Count-1; $i -ge 0; $i--) {
            if ([int]::TryParse($vernums[$i], [ref] $lastNum)) {
                $lastNumIdx = $i
                break
            }
        }#>
        
        $lastNum++
        $vernums[$component] = $lastNum.ToString()
        #each lesser component should be set to 0 
        for($i = $component + 1; $i -lt $vernums.length; $i++) {
            $vernums[$i] = 0
        }
    } else {
        if ([string]::IsNullOrEmpty($suffix)) {
            throw "version '$ver' has no suffix"
        }
        
        if ($component -eq [VersionComponent]::SuffixBuild) {
            if ($suffix -match "build([0-9]+)") {
                $num = [int]$matches[1]
                $num++
                $suffix = $suffix -replace "build[0-9]+","build$($num.ToString("###"))"
            }
            else {
                throw "suffix '$suffix' does not match build[0-9] pattern"
            }
        }
    }
    
    $ver2 = [string]::Join(".", $vernums)
    if (![string]::IsNullOrEmpty($suffix)) {
        $ver2 += "-$suffix"
    }

    return $ver2
}
