#/bin/bash

cd /source/protobufkdb/build
cmake ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd /source/protobufkdb

/bin/bash
