function Expand-WebArchive([string]$uri, [string]$runtime)
{
    $tmp = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString() + ".zip"
    Invoke-WebRequest -Uri $uri -OutFile $tmp
    $tmp | Expand-Archive -DestinationPath ./runtimes/$runtime/native
    $tmp | Remove-Item
}

git submodule update --init --recursive --quiet

$linuxUri   = "https://ci.appveyor.com/api/buildjobs/yqyton27jvhrveyy/artifacts/artifacts.zip"
$windowsUri = "https://ci.appveyor.com/api/buildjobs/39qb173mp0aa0u40/artifacts/artifacts.zip"

Expand-WebArchive $linuxUri "linux-x64"
Expand-WebArchive $windowsUri "win-x64"