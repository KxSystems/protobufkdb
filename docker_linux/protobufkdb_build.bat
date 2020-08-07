SETLOCAL

SET PROTOBUFKDB_SOURCE="C:\Git\protobufkdb\nmcdonnell-kx"
SET QHOME_LINUX="C:\q"

docker build -f Dockerfile.build -t protobufkdb-dev .
docker run --rm -it -v %QHOME_LINUX%:/q -v %PROTOBUFKDB_SOURCE%:/source/protobufkdb protobufkdb-dev /bin/bash -c /source/protobufkdb_build.sh

ENDLOCAL
