function Expand-WebArchiveUnix([string]$uri, [string]$runtime)
{
    $tmp = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString() + ".zip"
    Invoke-WebRequest -Uri $uri -OutFile $tmp
    mkdir -p ./runtimes/$runtime/native
    unzip $tmp -d ./runtimes/$runtime/native
    $tmp | Remove-Item
}

function Expand-WebArchiveWindows([string]$uri, [string]$runtime)
{
    $tmp = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString() + ".zip"
    Invoke-WebRequest -Uri $uri -OutFile $tmp
    $tmp | Expand-Archive -DestinationPath ./runtimes/$runtime/native
    $tmp | Remove-Item
}

git submodule update --init --recursive --quiet

$linuxUrl       = "https://github.com/HDFGroup/HDF.PInvoke.1.10/releases/download/v1.10.600-native/Linux_x64.zip"
$macOSUrl       = "https://github.com/HDFGroup/HDF.PInvoke.1.10/releases/download/v1.10.600-native/MacOS_x64.zip"
$windowsUrl_x64 = "https://github.com/HDFGroup/HDF.PInvoke.1.10/releases/download/v1.10.600-native/Windows_x64.zip"
$windowsUrl_x86 = "https://github.com/HDFGroup/HDF.PInvoke.1.10/releases/download/v1.10.600-native/Windows_x86.zip"

if ($IsLinux -Or $IsMacOs)
{
    Expand-WebArchiveUnix $linuxUrl "linux-x64"
    Expand-WebArchiveUnix $macOSUrl "osx-x64"
    Expand-WebArchiveUnix $windowsUrl_x64 "win-x64"
    Expand-WebArchiveUnix $windowsUrl_x86 "win-x86"
}
elseif ($IsWindows)
{
    Expand-WebArchiveWindows $linuxUrl "linux-x64"
    Expand-WebArchiveWindows $macOSUrl "osx-x64"
    Expand-WebArchiveWindows $windowsUrl_x64 "win-x64"
    Expand-WebArchiveWindows $windowsUrl_x86 "win-x86"
}
