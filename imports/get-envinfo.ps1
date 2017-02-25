function get-envinfo($checkcommands) {
    $result = @{} 
    
    write-verbose "Powershell version:"    
    $result.PSVersion = $PSVersionTable.PSVersion 
    $result.PSVersion | format-table | out-string | write-verbose
    
    write-verbose "Available commands:"
    if ($null -eq $checkcommands) {
        $commands = "Install-Module"
    } else {
        $commands = $checkcommands
    }
    $result.Commands = @{}    
    $commands | % {
        $c = $_
        $cmd = $null
        try {
            $cmd = get-command $c -ErrorAction SilentlyContinue
            if ($null -ne $cmd) {
                $result.Commands[$_] = $cmd
            }
        } catch {
            write-error $_
            $cmd = $null
        }
        if ($null -eq $cmd) {
            write-warning "$($c):`t MISSING COMMAND"            
        }
        else {
             write-verbose "$($c):`t $(($cmd | format-table -HideTableHeaders | out-string) -replace ""`r`n"",'')"
        }
    }

    return $result
    
}
