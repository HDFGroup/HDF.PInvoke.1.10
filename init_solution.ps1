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

$linuxUrl       = "https://ci.appveyor.com/api/buildjobs/wsrah2ibo2ekkib3/artifacts/artifacts.zip"
$macOSUrl       = "https://github.com/Apollo3zehn/HDF.PInvoke.NETStandard/releases/download/v1.10.500-preview1-native/artifacts.zip"
$windowsUrl_x64 = "https://ci.appveyor.com/api/buildjobs/2r8y9a31d1wnyaj9/artifacts/artifacts.zip"
$windowsUrl_x86 = "https://ci.appveyor.com/api/buildjobs/pkkkikt92htefba0/artifacts/artifacts.zip"

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
