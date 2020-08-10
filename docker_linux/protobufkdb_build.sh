#/bin/bash

mkdir /source/build
cd /source/build
cmake -DCMAKE_PREFIX_PATH=$PROTOBUF_INSTALL ../protobufkdb
cmake --build . --config Release
cmake --build . --config Release --target install
cd /source/protobufkdb

/bin/bash
