# define parameters
$version1 = "1.10.5"
$version2 = "1_10_5"
$topFolderName = "CMake-hdf5-$version1"
$sourceFolderName = "hdf5-$version1"

if     ($IsLinux)   { $extension = "tar.gz" }
elseif ($IsMacOs)   { $extension = "tar.gz" }
elseif ($IsWindows) { $extension = "zip" }

$url = "https://s3.amazonaws.com/hdf-wordpress-1/wp-content/uploads/manual/HDF5/HDF5_$version2/source/CMake-hdf5-$version1.$extension"

# download and extract source files
Invoke-WebRequest -Uri $url -OutFile archive.$extension

if     ($isLinux)   { tar xzf archive.$extension }
elseif ($isWindows) { Expand-Archive -Path archive.$extension -DestinationPath . }

# create build folder
New-Item -Path ./$topFolderName/build -ItemType directory
Set-Location -Path ./$topFolderName/build

# define CMAKE options
$params = @"
-DCMAKE_BUILD_TYPE:STRING=Release
-DBUILD_SHARED_LIBS:BOOL=ON
-DBUILD_TESTING:BOOL=OFF

-DHDF5_BUILD_CPP_LIB:BOOL=OFF
-DHDF5_BUILD_EXAMPLES:BOOL=OFF
-DHDF5_BUILD_FORTRAN:BOOL=OFF
-DALLOW_UNSUPPORTED:BOOL=ON
-DHDF5_BUILD_HL_LIB:BOOL=ON
-DHDF5_BUILD_JAVA:BOOL=OFF
-DHDF5_BUILD_TOOLS:BOOL=OFF
-DHDF5_ENABLE_THREADSAFE:BOOL=ON

-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING=TGZ
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON
-DHDF5_ENABLE_SZIP_ENCODING:BOOL=ON
-DZLIB_TGZ_NAME:STRING=ZLib.tar.gz
-DSZIP_TGZ_NAME:STRING=SZip.tar.gz
-DTGZPATH:PATH=$((Get-Location).Path)/..
"@.replace("`n"," ")

# create build files
if     ($IsLinux)   { Invoke-Expression "cmake -G 'Unix Makefiles' $params ./../$sourceFolderName" }
if     ($IsMacOs)   { Invoke-Expression "cmake -G 'Unix Makefiles' $params ./../$sourceFolderName" }
elseif ($IsWindows -And $env:PLATFORM -eq "x64") { Invoke-Expression "cmake -G 'Visual Studio 15 2017 Win64' $params ./../$sourceFolderName" }
elseif ($IsWindows -And $env:PLATFORM -eq "x86") { Invoke-Expression "cmake -G 'Visual Studio 15 2017'       $params ./../$sourceFolderName" }

# build
cmake --build . --config Release

# collect artifacts
if ($IsLinux)
{
    Set-Location -Path ./bin
    zip -y ./../../../artifacts.zip ./*.so*
}
if ($IsMacOs)
{
    Set-Location -Path ./bin
    zip -y ./../../../artifacts.zip ./*.so*
}
elseif ($IsWindows)
{
    Set-Location -Path ./bin/release
    Compress-Archive -Path ./*.dll -DestinationPath ./../../../../artifacts.zip
}