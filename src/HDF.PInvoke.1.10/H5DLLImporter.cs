/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using hid_t = System.Int64;

namespace HDF.PInvoke
{
    // Only for compatiblity with the HDF.PInvoke version referenced in submodule
    public static class NativeDependencies
    {
        public static void ResolvePathToExternalDependencies() { }
    }

    internal abstract class H5DLLImporter
    {
        public static readonly H5DLLImporter Instance;

        static H5DLLImporter()
        {
            if (H5.open() < 0)
                throw new Exception("Could not initialize HDF5 library.");

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                Instance = new H5LinuxDllImporter(Constants.DLLFileName);

            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                Instance = new H5MacDllImporter(Constants.DLLFileName);

            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                Instance = new H5WindowsDLLImporter(Constants.DLLFileName);

            else
                throw new PlatformNotSupportedException();
        }

        protected abstract IntPtr InternalGetAddress(string varName);

        public IntPtr GetAddress(string varName)
        {
            var address = this.InternalGetAddress(varName);
            if (address == IntPtr.Zero)
                throw new Exception(string.Format("The export with name \"{0}\" doesn't exist.", varName));
            return address;
        }

        public unsafe hid_t GetHid(string varName)
        {
            return *(hid_t*)this.GetAddress(varName);
        }
    }

    internal class H5WindowsDLLImporter : H5DLLImporter
    {
        [DllImport("kernel32.dll")]
        internal static extern IntPtr GetModuleHandle(string lpszLib);

        [DllImport("kernel32.dll")]
        internal static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        private IntPtr _handle;

        public H5WindowsDLLImporter(string libName)
        {
            _handle = GetModuleHandle(libName);

            if (_handle == IntPtr.Zero)
                throw new DllNotFoundException(libName);
        }

        protected override IntPtr InternalGetAddress(string varName)
        {
            return GetProcAddress(_handle, varName);
        }
    }

    internal class H5LinuxDllImporter : H5DLLImporter
    {
        [DllImport("libdl.so.2")]
        protected static extern IntPtr dlopen(string filename, int flags);

        [DllImport("libdl.so.2")]
        protected static extern IntPtr dlsym(IntPtr handle, string symbol);

        [DllImport("libdl.so.2")]
        protected static extern IntPtr dlerror();

        private const int RTLD_NOW = 2;
        private IntPtr _handle;

        // The library is already loaded, otherwise H5.open() above would not have been called successfully.
        // However, to get the lib handle for the symbols, we need to "reopen" it using the correct path.
        public H5LinuxDllImporter(string libName)
        {
            var fileName = $"lib{libName}.so";
            var filePath = File
                .ReadAllText("/proc/self/maps")
                .Split('\n')
                .Where(line => line.Contains(fileName))
                .FirstOrDefault();

            if (filePath == null || !File.Exists(filePath))
                throw new FileNotFoundException(fileName);

            _handle = dlopen(filePath, RTLD_NOW);

            if (_handle == IntPtr.Zero)
                throw new DllNotFoundException(libName);
        }

        protected override IntPtr InternalGetAddress(string varName)
        {
            var address = dlsym(_handle, varName);
            var errPtr = dlerror();

            if (errPtr != IntPtr.Zero)
                throw new Exception("dlsym: " + Marshal.PtrToStringAnsi(errPtr));

            return address;
        }
    }

    internal class H5MacDllImporter : H5DLLImporter
    {
        [DllImport("libdl.dylib")]
        protected static extern IntPtr dlopen(string filename, int flags);

        [DllImport("libdl.dylib")]
        protected static extern IntPtr dlsym(IntPtr handle, string symbol);

        [DllImport("libdl.dylib")]
        protected static extern IntPtr dlerror();

        private const int RTLD_NOW = 2;
        private IntPtr _handle;

        // The library is already loaded, otherwise H5.open() above would not have been called successfully.
        // However, to get the lib handle for the symbols, we need to "reopen" it using the correct path.
        public H5MacDllImporter(string libName)
        {
            string filePath;

            var fileName = $"lib{libName}.dylib";
            var basePath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var localPath = Path.Combine(basePath, fileName);
            var packagePath = Path.Combine(basePath, "..", "..", "runtimes", "osx-x64", "native", fileName);

            if (File.Exists(localPath))
                filePath = localPath;
            else if (File.Exists(packagePath))
                filePath = packagePath;
            else
                throw new FileNotFoundException(libName);

            _handle = dlopen(filePath, RTLD_NOW);

            if (_handle == IntPtr.Zero)
                throw new DllNotFoundException(libName);
        }

        protected override IntPtr InternalGetAddress(string varName)
        {
            var address = dlsym(_handle, varName);
            var errPtr = dlerror();

            if (errPtr != IntPtr.Zero)
                throw new Exception("dlsym: " + Marshal.PtrToStringAnsi(errPtr));

            return address;
        }
    }
}