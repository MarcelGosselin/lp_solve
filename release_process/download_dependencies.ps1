# Requires to have 7z.exe in PATH
function Download-GLPK {
    param (
        [string]$Version,
        [string]$Destination
    )

    $tempFolder = [System.IO.Path]::GetTempFileName()
    Remove-Item $tempFolder
    New-Item -ItemType Directory -Path $tempFolder
    $tarGzPath    = Join-Path $tempFolder "glpk-$Version.tar.gz"
    $tarPath      = Join-Path $tempFolder "glpk-$Version.tar"
    $untarredPath = Join-Path $tempFolder "glpk-$Version"

    # official download link is http://ftpmirror.gnu.org/gnu/glpk/glpk-$Version.tar.gz but is has version 4.35 and up only
    # for older versions we should use https://ftp.gnu.org/old-gnu/glpk/glpk-$Version.tar.gz but it lacks versions 3.2.3-4.34
    # so we use  https://slackware.cs.utah.edu/pub/gnu/glpk/glpk-$Version.tar.gz which sometimes is too busy and fails with:
    #    A connection attempt failed because the connected party did not properly respond after a period of time.
    $downloadUri = "http://ftpmirror.gnu.org/gnu/glpk/glpk-$Version.tar.gz"
    if ([version]$Version -lt [version]"4.35") {
        $downloadUri = "https://slackware.cs.utah.edu/pub/gnu/glpk/glpk-$Version.tar.gz"
    }

    New-Item -ItemType Directory -Path $Destination
    Invoke-WebRequest -Uri $downloadUri -OutFile $tarGzPath
    7z x $tarGzPath -o"$tempFolder" # creates file at $tarPath
    7z x -aoa -ttar -spe $tarPath -o"$untarredPath"
    Move-Item -Path $untarredPath\* -Destination $Destination

    # Cleanup
    rm $tempFolder -Recurse
}

function Download-MySQLConnectorC {
    param (
        [string]$Version,
        [string]$Destination,
        [bool]$Is32Bit = $false
    )

    $arch = if ($Is32Bit) { "win32" } else { "winx64" }
    $zipFileWithoutExtension = "mysql-connector-c-noinstall-$Version-$arch"
    $url = "https://cdn.mysql.com/archives/mysql-connector-c/$zipFileWithoutExtension.zip"

    $tempFolder = [System.IO.Path]::GetTempFileName()
    Remove-Item $tempFolder
    New-Item -ItemType Directory -Path $tempFolder
    $zipPath      = Join-Path $tempFolder "$zipFileWithoutExtension.zip"
    $unzippedPath = Join-Path $tempFolder $zipFileWithoutExtension

    New-Item -ItemType Directory -Path $Destination
    Invoke-WebRequest -Uri $url -OutFile $zipPath
    7z x $zipPath -o"$tempFolder" # creates file at $unzippedPath
    Move-Item -Path $unzippedPath\* -Destination $Destination

    # Cleanup
    rm $tempFolder -Recurse
}

function Download-AMPL {
    param (
        [string]$Destination
    )

    $tempFolder = [System.IO.Path]::GetTempFileName()
    Remove-Item $tempFolder
    New-Item -ItemType Directory -Path $tempFolder
    $tarGzPath    = Join-Path $tempFolder "solvers.tgz"
    $tarPath      = Join-Path $tempFolder "solvers.tar"
    $untarredPath = Join-Path $tempFolder "solvers"

    Invoke-WebRequest -Uri https://www.netlib.org/ampl/solvers.tgz -OutFile $tarGzPath
    7z x $tarGzPath -o"$tempFolder" # creates file at $tarPath
    7z x -aoa -ttar -spe $tarPath -o"$untarredPath"
    Move-Item -Path $untarredPath\* -Destination $Destination

    # Cleanup
    rm $tempFolder -Recurse
}
