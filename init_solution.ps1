function Expand-WebArchiveLinux([string]$uri, [string]$runtime)
{
    $tmp = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString() + ".zip"
    Invoke-WebRequest -Uri $uri -OutFile $tmp
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

$linuxUri   = "https://ci.appveyor.com/api/buildjobs/yqyton27jvhrveyy/artifacts/artifacts.zip"
$windowsUri = "https://ci.appveyor.com/api/buildjobs/39qb173mp0aa0u40/artifacts/artifacts.zip"

if ($isLinux)
{
    Expand-WebArchiveLinux $linuxUri "linux-x64"
    Expand-WebArchiveLinux $windowsUri "win-x64"
}
elseif ($isWindows)
{
    Expand-WebArchiveWindows $linuxUri "linux-x64"
    Expand-WebArchiveWindows $windowsUri "win-x64"
}