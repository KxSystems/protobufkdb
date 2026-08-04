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

cmake -DQMOD=ON \
      -DSTATIC_LINK=OFF \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH \
      -DCMAKE_INSTALL_PREFIX=$PREFIX/lib/q/mod/kx \
      -DCMAKE_OSX_ARCHITECTURES=$OSX_ARCH \
      ..

cmake --build . --config $BUILD_TYPE

cmake --build . --config $BUILD_TYPE --target install

