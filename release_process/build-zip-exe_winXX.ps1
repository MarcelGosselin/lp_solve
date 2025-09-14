. $PSScriptRoot/check_env_vars.ps1
$requiredEnvVars = @("LPSOLVE_WORKSPACE", "LPSOLVE_VERSION", "LPSOLVE_PLATFORM")
Assert-EnvironmentVariablesAreNotEmpty $requiredEnvVars

$zipContentFolder = Join-Path ${env:Temp} "exe_${env:LPSOLVE_VERSION}_zip_content"
if (Test-Path -LiteralPath $zipContentFolder) {
    Remove-Item -LiteralPath $zipContentFolder -Verbose -Recurse -Force
}
New-Item -ItemType Directory -Path $zipContentFolder

echo "Building lp_solve.exe for platform ${env:LPSOLVE_PLATFORM}"
cd ${env:LPSOLVE_WORKSPACE}/lp_solve
./cvc8.bat
cp ${env:LPSOLVE_WORKSPACE}/lp_solve/bin/${env:LPSOLVE_PLATFORM}/lp_solve.exe $zipContentFolder

# TODO: we currently have version conflicts on the GLPK library used by bfp_GLPK and xli_MathProg
#       in version 5.5.2.0 of lp_solve, it upgraded from GLPK 4.13 to 4.44 for xli_MathProg but not for "bfp_GLPK"
#       For this reason we won't built "bfp_GLPK" nor "xli_MathProg" right now
$bfpFolders = "bfp_etaPFI", "bfp_LUSOL" # "bfp_GLPK"
foreach ($bfpFolder in $bfpFolders) {
    echo "Building $bfpFolder.dll for platform $env:LPSOLVE_PLATFORM"
    cd ${env:LPSOLVE_WORKSPACE}/bfp/$bfpFolder
    ./cvc8NOmsvcrt.bat
    cp ${env:LPSOLVE_WORKSPACE}/bfp/$bfpFolder/bin/${env:LPSOLVE_PLATFORM}/$bfpFolder.dll $zipContentFolder
}

# TODO: see comment about GLPK and xli_MathProg above
$xliFolders = "xli_CPLEX", "xli_DIMACS", "xli_LINDO", "xli_MPS", "xli_XPRESS" # "xli_MathProg"
if ( $env:LPSOLVE_PLATFORM -eq "win32" ) {
    # issues building them for now
    # $xliFolders += "xli_LPFML", "xli_ZIMPL"
}
foreach ($xliFolder in $xliFolders) {
    echo "Building $xliFolder.dll for platform $env:LPSOLVE_PLATFORM"
    cd ${env:LPSOLVE_WORKSPACE}/xli/$xliFolder
    ./cvc8NOmsvcrt.bat
    cp ${env:LPSOLVE_WORKSPACE}/xli/$xliFolder/bin/${env:LPSOLVE_PLATFORM}/$xliFolder.dll $zipContentFolder
}

cp ${env:LPSOLVE_WORKSPACE}/release_process/contents_exe_${env:LPSOLVE_PLATFORM}.txt $zipContentFolder/contents.txt

$zipPath = "${env:LPSOLVE_WORKSPACE}/lp_solve_${env:LPSOLVE_VERSION}_exe_${env:LPSOLVE_PLATFORM}.zip"

cd $zipContentFolder
echo "Packaging files from ${PWD} into ${zipPath}"
7z a -tzip -bso0 -bsp0 $zipPath *
