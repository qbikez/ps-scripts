Import-Module csproj
import-module crayon

get-nugettoolspath | % { 
    Log-Info "adding ``cyan``$_``d`` to PATH"; 
    gci $_\*.* -Include *.exe,*.bat,*.cmd | % { log-info " >> '$($_.Name)'" } ; 
    $_ 
} | add-topath