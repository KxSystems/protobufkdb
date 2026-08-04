mkdir %SRC_DIR%\build
cd %SRC_DIR%\build

set BUILD_TYPE=RelWithDebInfo
:: set BUILD_TYPE=Release
:: set BUILD_TYPE=Debug

echo CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH%

cmake -G "NMake Makefiles" ^
      -DQMOD=ON ^
      -DSTATIC_LINK=OFF ^
      -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -DCMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%\lib\q\mod\kx" ^
       %SRC_DIR%
if errorlevel 1 exit \b 1

cmake --build . --config %BUILD_TYPE%
if errorlevel 1 exit \b 1

cmake --build . --config %BUILD_TYPE% --target install
if errorlevel 1 exit \b 1
