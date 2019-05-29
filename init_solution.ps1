function Expand-WebArchiveLinux([string]$uri, [string]$runtime)
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

$linuxUrl       = "https://ci.appveyor.com/api/buildjobs/rqfxh3nd3vxb44t1/artifacts/artifacts.zip"
$windowsUrl_x64 = "https://ci.appveyor.com/api/buildjobs/375h5vbdbgo29xei/artifacts/artifacts.zip"
$windowsUrl_x86 = "https://ci.appveyor.com/api/buildjobs/71yl34l1oha5sity/artifacts/artifacts.zip"

if ($isLinux)
{
    Expand-WebArchiveLinux $linuxUrl "linux-x64"
    Expand-WebArchiveLinux $windowsUrl_x64 "win-x64"
    Expand-WebArchiveLinux $windowsUrl_x86 "win-x86"
}
elseif ($isWindows)
{
    Expand-WebArchiveWindows $linuxUrl "linux-x64"
    Expand-WebArchiveWindows $windowsUrl_x64 "win-x64"
    Expand-WebArchiveWindows $windowsUrl_x86 "win-x86"
}
