#!/bin/bash
set -e
set -x

mkdir -p build/install
cd build

echo BUILD_PREFIX=$BUILD_PREFIX
echo CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH

BUILD_TYPE=RelWithDebInfo

# Determine OSX architecture from the target platform
if [[ "$target_platform" == "osx-arm64" ]]; then
    OSX_ARCH="arm64"
elif [[ "$target_platform" == "osx-64" ]]; then
    OSX_ARCH="x86_64"
else
    OSX_ARCH=$(uname -m)
fi

# Point at $PREFIX rather than forwarding $CMAKE_PREFIX_PATH: conda activation
# exports that as a colon-separated PATH-style list with a leading empty entry
# (":$PREFIX").  CMake only converts ":" to ";" for the *environment* variable,
# so a literal -D of it is one non-existent path; the prefix search then finds
# nothing, find_package(Protobuf CONFIG) falls through to the default system
# paths, and on macOS runners that is Homebrew's x86_64 protobuf in /usr/local,
# which fails to link (and ignores the libprotobuf variant being built).
# The root CMakeLists.txt also globs ${CMAKE_PREFIX_PATH}/include, so this has
# to stay a single directory.
PROTOBUF_PREFIX=$PREFIX

# Belt and braces: keep anything that escapes the prefix search away from the
# Homebrew trees, whose protobuf reports the same config-package version as
# conda's.  Turns a silent wrong-architecture link into an explicit
# "protobuf not found" at configure time.
IGNORED_PREFIXES="/usr/local;/opt/homebrew"

# Which CMake packages the host prefix actually provides.  If protobuf is not
# among them the configure below now fails outright rather than quietly linking
# whatever protobuf happens to be installed system-wide.
ls -d $PREFIX/lib/cmake/* 2>/dev/null || echo "no CMake packages under $PREFIX/lib/cmake"

cmake ${CMAKE_ARGS} \
      -DQMOD=ON \
      -DSTATIC_LINK=OFF \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_PREFIX_PATH=$PROTOBUF_PREFIX \
      -DCMAKE_IGNORE_PREFIX_PATH="$IGNORED_PREFIXES" \
      -DCMAKE_INSTALL_PREFIX=$PREFIX/lib/q/mod/kx \
      -DCMAKE_OSX_ARCHITECTURES=$OSX_ARCH \
      ..

cmake --build . --config $BUILD_TYPE

cmake --build . --config $BUILD_TYPE --target install

