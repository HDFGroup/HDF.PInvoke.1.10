## HDF.PInvoke.NETStandard

This project is based on [HDF.PInvoke for .NET Framework](https://github.com/HDFGroup/HDF.PInvoke) and aims to bring it to .NET Standard 2.0+. The first supported version is HDF5 [1.10.5](https://portal.hdfgroup.org/display/support/Downloads) for Windows (x86, x64) and Linux (x64). Support for OSX will be added in futures version when the CI provider ([AppVeyor](https://www.appveyor.com/)) supports building on OSX or using [Travis](https://travis-ci.org/) as an alternative.

![AppVeyor Project status badge](https://ci.appveyor.com/api/projects/status/github/HDFGroup/HDF.PInvoke.NETStandard?branch=master&svg=true)
[![NuGet](https://img.shields.io/nuget/v/HDF.PInvoke.NETStandard.svg?label=Nuget)](https://www.nuget.org/packages/HDF.PInvoke.NETStandard)
[![Gitter](https://badges.gitter.im/HDFGroup/HDF.PInvoke.svg)](https://gitter.im/HDFGroup/HDF.PInvoke?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
<a href="https://groups.google.com/forum/#!forum/sharp-hdf5"><img src="https://groups.google.com/forum/my-groups-color.png" width="35" height="35"></a>

## What it is (not)

HDF.PInvoke.NETStandard is a collection of [PInvoke](https://en.wikipedia.org/wiki/Platform_Invocation_Services)
signatures for the [HDF5 C-API](https://www.hdfgroup.org/HDF5/doc/RM/RM_H5Front.html).
It's practically *code-free*, which means we can blame all the bugs on Microsoft or [The HDF Group](https://www.hdfgroup.org/) :smile:

It is **not** a high-level .NET interface for HDF5. "It's the [GCD](https://en.wikipedia.org/wiki/Greatest_common_divisor)
of .NET bindings for HDF5, not the [LCM](https://en.wikipedia.org/wiki/Least_common_multiple)." :bowtie:

## Quick Install

To install the latest version, run the following command in the
[Package Manager Console](https://docs.nuget.org/docs/start-here/using-the-package-manager-console):

```
dotnet add package HDF.PInvoke.NETStandard -Version 1.10.5.0-preview1
```

## Prerequisites

The ``HDF.PInvoke.dll`` managed assembly depends on the following native libraries:
- HDF5 core API, ``hdf5.dll`` / ``libhdf5.so``
- HDF5 high-level APIs, ``hdf5_hl.dll`` / ``libhdf5_hl.so``
- The C-runtime of the Visual Studio version used to build the former, i.e., ``msvcr140.dll`` for Visual Studio 2015 / 2017

All native dependencies, built with [thread-safety enabled](https://support.hdfgroup.org/HDF5/faq/threadsafe.html),
are included in the NuGet packages,
**except** the Visual Studio C-runtime, which is available from Microsoft as [Visual C++ Redistributable Packages for Visual Studio 2017](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads). In the unlikely event that they aren't already installed on your system, go get 'em!)

## The Library Resolution Process

When you include HDF.PInvoke.NETStandard in your project via NuGet (```<PackageReference>``` in ```.csproj``` file), the native libraries are resolved automatially by the runtime. The dependencies are placed within the ```runtimes``` folder in a structure following [this](https://docs.microsoft.com/en-us/nuget/create-packages/supporting-multiple-target-frameworks#architecture-specific-folders) convention.

However, if you clone this repository, add a new project and create a ```<ProjectReference>``` to ```HDF.PInvoke.NETStandard.csproj```, there is no easy way yet to resolve depending native libraries (see [dotnet/sdk#765](https://github.com/dotnet/sdk/issues/765)). With the upcoming release of .NET Core 3.0, there will be some improvements, which enable the implementation of custom resolution logic for native libraries using the new ```NativeResolveEvent```.

In the meantime, the file ```Directory.Build.targets``` in this repository is responsible for copying the correct libraries to the project's output folder. When you are on Linux, the ```*.so``` files are copied. When you are on Windows and the ```<PlatformTarget>``` properties is not set to ```x86```, the 64-bit DLL's are copied. The targets file is automatically included in projects that are located within any subfolder and use the new ```.csproj``` format.

## Building the Managed Library

Before build, two things need to be prepared:

1. Initialization of the [HDF.PInvoke](https://github.com/HDFGroup/HDF.PInvoke) submodule via
```git submodule update --init --recursive --quiet```
2. Preparation of the ```runtimes``` folder, i.e. download of platform specific versions of the ```hdf5``` and ```hdf_hl``` files (see also: [Building the Native Libraries](#native)).

Since the second step consists of more than a single line of code, the it is simpler to call the [Powershell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6) script: ```./init_solution.ps1```.

You can then build the actual library and NuGet package with:

```
dotnet build ./src/HDF.PInvoke.NETStandard/HDF.PInvoke.NETStandard.csproj -c Release
```

The output written to the ```artifacts``` folder, where the ```bin```, ```obj``` and ```packages``` folders are located.

The unit tests can be executed with:

```
dotnet test ./test/UnitTests/UnitTests.csproj
```

## <a name="native"></a>Building the Native Libraries

The native libraries are built using the [native-CI](https://github.com/HDFGroup/HDF.PInvoke.NETStandard/tree/native-CI) branch. Each build produces a ```.zip``` file containig the platform specific files. The following settings are used for building:

| Option                       | Value       |
| ---------------------------- | ----------- |
| CMAKE_BUILD_TYPE             | Release     | 
| BUILD_SHARED_LIBS            | ON          | 
| ALLOW_UNSUPPORTED            | ON          | 
| HDF5_BUILD_HL_LIB            | ON          | 
| HDF5_ENABLE_THREADSAFE       | ON          | 
| HDF5_ALLOW_EXTERNAL_SUPPORT  | ON (TGZ)    | 
| HDF5_ENABLE_Z_LIB_SUPPORT    | ON          | 
| HDF5_ENABLE_SZIP_SUPPORT     | ON          | 
| HDF5_ENABLE_SZIP_ENCODING    | ON          | 


## License

HDF.PInvoke is part of [HDF5](https://www.hdfgroup.org/HDF5/). It is subject to the *same* terms and conditions as HDF5. Please review [COPYING](COPYING) or [https://support.hdfgroup.org/ftp/HDF5/releases/COPYING](https://support.hdfgroup.org/ftp/HDF5/releases/COPYING) for the details. If you have any questions, please [contact us](http://www.hdfgroup.org/about/contact.html).

## Supporting HDF.PInvoke(.NETStandard)

The best way to support HDF.PInvoke.NETStandard is to contribute to it either by reporting
bugs, writing documentation (e.g., the [cookbook](https://github.com/HDFGroup/HDF.PInvoke/wiki/Cookbook)),
or sending pull requests.

***

![The HDF Group logo](https://github.com/HDFGroup/HDF.PInvoke/blob/master/images/The%20HDF%20Group.jpg)
