SETLOCAL

SET PROTOBUFKDB_SOURCE="C:\Git\protobufkdb\nmcdonnell-kx"
SET MODULE_DIR="C:\kx\mod"

docker build -f Dockerfile.build -t protobufkdb-dev .
docker run --rm -it -v %MODULE_DIR%:/mod -v %PROTOBUFKDB_SOURCE%:/source/protobufkdb protobufkdb-dev /bin/bash -c /source/protobufkdb_build.sh

ENDLOCAL
