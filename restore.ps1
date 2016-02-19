[CmdletBinding()]
param($path = ".")

if (test-path "$path\.git") {
     write-host "restoring git submodules"
     git submodule update --init --recursive
}

write-host  "installing 'Pester' module"
install-module pester -Verbose -Confirm:$false