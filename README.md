# protobufkdb

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/protobufkdb?include_prereleases)](https://github.com/kxsystems/protobufkdb/releases) [![Travis (.org) branch](https://img.shields.io/travis/kxsystems/protobufkdb/master?label=travis%20build)](https://travis-ci.org/kxsystems/protobufkdb/branches)

## Introduction

This interface allows kdb+ users to parse data which has been encoded using Google Protocol Buffers [(protobuf)](https://github.com/protocolbuffers/protobuf) into kdb according to the proto schema and serialise it back to the encoded wire format. The interface utilises the libprotobuf descriptor and reflection C++  [APIs](https://developers.google.com/protocol-buffers/docs/reference/cpp#google.protobuf).

This is part of the [*Fusion for kdb+*](http://code.kx.com/q/interfaces/fusion/) interface collection.



## New to kdb+ ?

Kdb+ is the world's fastest time-series database, optimized for  ingesting, analyzing and storing massive amounts of structured data. To  get started with kdb+, please visit https://code.kx.com/q/learn/ for downloads and developer information. For general information, visit https://kx.com/



## New to Protocol Buffers ?

Protocol Buffers (Protobuf) is a language-neutral, platform-neutral, extensible mechanism for serializing structured data. It is used both in the development of programs which are required to communicate over the wire or for data storage. Developed originally for internal use by Google, it is released under an open source BSD license. The core principle behind this data format is to allow a user to define the expected structure of their data and incorporate this within specially generated source code. This allows a user to easily read and write structured data to and from a variety of languages. You can find [protobuf's documentation on the Google Developers site](https://developers.google.com/protocol-buffers/docs/overview).



## Importing protobuf schema files

Protobuf messages are defined in a `.proto` schema file and these message definitions must be imported into the interface in order for it to be able to create messages of those types.  The interface supports two ways to do this (or a combination of both) but the method used will impact how protobufkdb should be installed.

### 1.  Compiling in the generated message definitions

Normally the protocol buffers compiler is used to generate source code from the `.proto` schema files which is then compiled in to the binary:

protoc compiles your message definitions based on a file defined as:

```bash
<schema>.proto
```

producing both a C++ source and header file defined as:

```bash
<schema>.pb.cc
<schema>.pb.h
```

These files contain the classes and metadata which describe the schema and the functionality required to serialise to and parse from this schema.

This mechanism is more performant but does require that protobufkdb be built from source since the binary needs to be rebuilt to change the statically available messages.

### 2.  Dynamically importing the message definitions at runtime

In order to provide greater flexibility and usability it is also possible to dynamically import a `.proto` schema file at runtime from within the q session.  Imported message definitions can then be used subsequently by the interface and behave similarly to compiled in ones (the import procedure leverages the same functionality as used by the protobuf compiler).

If only dynamically imported message definitions are required then the packaged installation of protobufkdb can be used.  However, importing message definitions is less performant - in addition to the one off import cost there is also an overhead from the subsequent use of these dynamically created messages (approx. 10% for parsing, 20% for serialising).  Alternatively a hybrid approach can be employed where dynamic messages are used during development until the schemas are finalised at which point they are compiled into the interface.



## Installation

### Requirements

- kdb+ ≥ 3.5 64-bit (Linux/MacOS/Windows)
- protobuf ≥ 3.0 (recommended [^1])
- C++11 or later [^2] 
- CMake ≥ 3.1 [^2]

[^1]: Protocol Buffers language version 3 ([proto3](https://developers.google.com/protocol-buffers/docs/proto3)) simplifies the protocol buffer language, both for ease of use and to make it available in a  wider range of programming languages.  However, schemas defined in [proto2](https://developers.google.com/protocol-buffers/docs/cpptutorial) should also be supported.

[^2]: Required when building from source

### Installing a release

The protobufkdb releases are linked statically against libprotobuf to avoid potential C++ ABI [compatibility issues](https://github.com/protocolbuffers/protobuf/tree/master/src#binary-compatibility-warning) with different versions of libprotobuf.  Therefore it is not necessary to install protobuf separately when used a packaged release.

1. Download a release from [here](https://github.com/KxSystems/protobufkdb/releases)

2. Install required q executable script `q/protobufkdb.q` and binary file `lib/protobufkdb.(so|dll)` to `$QHOME` and `$QHOME/[mlw](64)`, by executing the following from the Release directory

   ```bash
   ## Linux/MacOS
   chmod +x install.sh && ./install.sh
   
   ## Windows
   install.bat
   ```

3. If you wish to use the KdbTypeSpecifier field option (described below) with dynamic messages then the directory containing `kdb_type_specifier.proto` must be specified to the interface as an import search location.  In the release package `kdb_type_specifier.proto` (and its dependencies) are found in the `proto` subdirectory.  Import paths can be relative or absolute.  For example, if the q session is started from the root of the release package run:

   ```
   q).protobufkdb.addProtoImportPath["proto"]
   ```

### Building and installing from source

#### Third-Party Library Installation

Protobufkdb requires the full protocol buffers runtime (protoc compiler, libprotobuf and its header files) to be installed on your system.  Many packaged installations only contain a subset of the required functionality or use an incompatible build.  Furthermore, version mismatches can occur between protoc and libprotobuf if a new installation is applied on top of an existing one.  

It is therefore recommend that the protocol buffer runtime is built from source and installed to a non-system directory.  This directory can then be specified to the protobufkdb build so it will use that protocol buffers installation in preference to any existing system installs.

#### Building protocol buffers - Linux/MacOS

The tools required to build protocol buffers from source on Linux/MacOS are described [here](https://github.com/protocolbuffers/protobuf/blob/master/src/README.md).  Then follow the below instructions to build protocol buffers with the correct compiler options and install it to a non-system directory.

Clone the protocol buffers source from github:

```bash
$ git clone https://github.com/protocolbuffers/protobuf.git
$ cd protobuf
$ ./autogen.sh
```

Create an install directory and set an environment variable to this directory (this is used again later when building protobufkdb):

```bash
$ mkdir install
$ export PROTOBUF_INSTALL=$(pwd)/install
```

Configure protocol buffers to build with C/C++ flag `-fPIC` (otherwise symbol relocation errors will occur during linking of protobufkdb) and to install it to the directory created above:

```bash
$ ./configure --prefix=$PROTOBUF_INSTALL "CFLAGS=-fPIC" "CXXFLAGS=-fPIC"
```

Finally build and install protocol buffers:

```bash
$ make
$ make install
```

#### Building protocol buffers - Windows

The tools required to build protocol buffers from source on Windows are described [here](https://github.com/protocolbuffers/protobuf/blob/master/cmake/README.md) and details on how to setup your environment to build with VS2019 are [here](https://github.com/protocolbuffers/protobuf/blob/master/cmake/README.md#environment-setup). Then follow the below instructions to build a Release version protocol buffers and install it to a non-system directory.

From a Visual Studio command prompt, clone the protocol buffers source from github:

```bash
C:\Git> git clone https://github.com/protocolbuffers/protobuf.git
C:\Git> cd protobuf
```

Create an install directory and set an environment variable to this directory (substituting the correct absolute path as appropriate).  This environment variable is used again later when building protobufkdb:

```bash
C:\Git\protobuf> mkdir install
C:\Git\protobuf> set PROTOBUF_INSTALL=C:\Git\protobuf\install
```

Create the CMake build directory (note that if you also wish to build a Debug version of protocol buffers then a second CMake build directory is required):

```bash
C:\Git\protobuf> mkdir cmake\release_build
C:\Git\protobuf> cd cmake\release_build
```

Generate the build files (this will default to using the Visual Studio CMake generator when run from a VS command prompt):

```bash
C:\Git\protobuf\cmake\release_build> cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=%PROTOBUF_INSTALL% ..
```

Finally build and install protocol buffers:

```bash
C:\Git\protobuf\cmake\release_build> cmake --build . --config Release
C:\Git\protobuf\cmake\release_build> cmake --build . --config Release --target install
```

#### Add the protobuf schema files to the build procedure

protobufkdb uses a factory to create a message class object of the correct type from the message type string passed from kdb.  The lookup requires that the message type string passed from kdb is the same as the message name in its .proto definition.

In order to populate the factory, the .proto files for all messages to be serialised/parsed must be incorporated into the build as follows:

1. Place the new `<schema>.proto` file into the `src/` subdirectory
2. Edit `src/CMakeLists.txt` file, adding the new .proto file to the line below the following comment:

  ```cmake
  # ### GENERATE PROTO FILES ###
  ```

  For example, to add `examples.proto` (which is already present in the `src/` subdirectory), in addition to the existing `tests.proto`, change:

  ```cmake
  set(MY_PROTO_FILES tests.proto)
  ```

  to:

  ```cmake
  set(MY_PROTO_FILES tests.proto examples.proto)
  ```

**Note:** `MY_PROTO_FILES` is a CMake space separated list, do not wrap the list of .proto files in a string.

#### Building protobufkdb

A CMake script is provided to build protobufkdb. This uses the CMake functionality to locate the protobuf installation on your system.  By setting the CMake environment variable `CMAKE_PREFIX_PATH` to the protocol buffers installation directory created above when building protobuf from source, CMake will use this installation in preference to any existing system installs.  This avoids issues with existing incompatible or mismatched protobuf installs.

From the root of this repository create and move into a directory in which to perform the build:

```bash
mkdir build && cd build
```

Generate the build scripts,  specifying the protobuf buffers installation created above when building protobuf from source (referenced by the environment variable `$PROTOBUF_INSTALL` which should have been set during that procedure):

```bash
## Linux/MacOS
cmake -DCMAKE_PREFIX_PATH=$PROTOBUF_INSTALL ..

## Windows
cmake -DCMAKE_PREFIX_PATH=%PROTOBUF_INSTALL% ..
```

Start the build:

```bash
cmake --build . --config Release
```

Create the install package and deploy:

```bash
cmake --build . --config Release --target install
```

**Note:**  By default `src/CMakeLists.txt` is configured to link statically against libprotobuf to avoid potential C++ ABI [compatibility issues](https://github.com/protocolbuffers/protobuf/tree/master/src#binary-compatibility-warning) with different versions of libprotobuf.  This is a particular issue on [Windows](https://github.com/protocolbuffers/protobuf/blob/master/cmake/README.md#dlls-vs-static-linking).

#### Build Issues

Because the protobufkdb interface uses both the protoc compiler and the protocol buffer's runtime, the versions of protoc, libprotobuf and its header files must be consistent and installed from the same build.  Otherwise build errors can occur when compiling any of the proto-generated `.pb.h` or `.pb.cc` files.  To help identify these problems the protobufkdb CMake scripts will log the locations of the protocol buffers installation it has found.  For example:

```bash
[build]$ cmake ..
 -- The CXX compiler identification is GNU 4.8.5
 -- Check for working CXX compiler: /usr/bin/c++
 -- Check for working CXX compiler: /usr/bin/c++ - works
 -- Detecting CXX compiler ABI info
 -- Detecting CXX compiler ABI info - done
 -- Detecting CXX compile features
 -- Detecting CXX compile features - done
 -- Generator : Unix Makefiles
 -- Build Tool : /usr/bin/gmake
 -- Proto files: tests.proto;examples.proto
 -- [ /usr/share/cmake3/Modules/FindProtobuf.cmake:321 ] Protobuf_USE_STATIC_LIBS = ON
 -- [ /usr/share/cmake3/Modules/FindProtobuf.cmake:455 ] requested version of Google Protobuf is
 -- [ /usr/share/cmake3/Modules/FindProtobuf.cmake:463 ] location of common.h: /usr/local/include/google/protobuf/stubs/common.h
 -- [ /usr/share/cmake3/Modules/FindProtobuf.cmake:481 ] /usr/local/include/google/protobuf/stubs/common.h reveals protobuf 3.7.1
 -- [ /usr/share/cmake3/Modules/FindProtobuf.cmake:495 ] /home/protobuf/install/bin/protoc reveals version 3.11.4
 -- Found Protobuf: /usr/local/lib/libprotobuf.a;-lpthread (found version "3.7.1")
 -- Configuring done
 -- Generating done
 -- Build files have been written to: /home/protobufkdb/build
```

indicates it found protoc version 3.11.4 at `/home/protobuf/install/bin/protoc` but version 3.7.1 of `libprotobuf.a` (and the headers) installed on the system under `/usr/local/`.  This can occur if there was a conflicting packaged version of protobuf already on the system and will likely cause the protobufkdb build to fail.  

The solution, as described above, is to build the protocol buffers runtime from source, install it to non-system directory then specify that directory when building protobufkdb.

#### Docker - Linux

A sample docker file is provided in the `docker_linux` directory to create a Ubuntu 18.04 LTS environment (including downloading and building the protocol buffers runtime from source) before building and installing the kdb+ `protobufkdb` interface.

For Docker Windows, the `PROTOBUFKDB_SOURCE` and `QHOME_LINUX` directories are specified at the top of `protobufkdb_build.bat`, which sets up the environment specified in `Dockerfile.build` and invokes `protobufkdb_build.sh` to build the interface.


## Status

The protobufkdb interface is provided here as a beta release under an Apache 2.0 license.

Protocol Buffers is used under the terms of [Google's license](https://github.com/protocolbuffers/protobuf/blob/master/LICENSE).

If you find issues with the interface or have feature requests, please consider raising an issue [here](https://github.com/KxSystems/protobufkdb/issues).

If you wish to contribute to this project, please follow the contributing guide [here](CONTRIBUTING.md).
