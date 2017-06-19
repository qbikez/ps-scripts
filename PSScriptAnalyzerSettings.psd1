# PSScriptAnalyzerSettings.psd1
@{
    Severity = @(
        'Error'
        'Warning'
   )
   Rules = @{
        'PSAvoidUsingCmdletAliases' = @{
            'Whitelist' = @('cd','%','select','where','pushd','popd','gi','Increment-Version')
        }
    }
    ExcludeRules=@(
        'PSAvoidUsingWriteHost'
        'PSUseApprovedVerbs'
        )
}