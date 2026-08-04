cmake_minimum_required(VERSION 3.5)
project(kxprotobuf CXX)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

option(QMOD "Build module" OFF)
option(STATIC_LINK ON)

if(NOT CMAKE_PREFIX_PATH)
	message(FATAL_ERROR "CMAKE_PREFIX_PATH must be set to the location of your protobuf installation directory")
endif()

message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")

if(CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(A l)
elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    set(A m)
elseif(CMAKE_SYSTEM_NAME STREQUAL Windows)
    set(A w)
else()
    message(FATAL_ERROR "Unsupported OS")
endif()

if(APPLE)
    if(CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
        set(A "${A}a64")
    elseif(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64")
        set(A "${A}i64")
    else()
        message(FATAL_ERROR "Unsupported macOS architecture")
    endif()
else()
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
        set(A "${A}i64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(A "${A}a64")
    else()
        message(FATAL_ERROR "Unsupported processor architecture")
    endif()
endif()

message(STATUS "A: ${A}")

set(MY_MODULE_NAME protobuf)

# A limitation of cmake protobuf support is that the .proto files must be in 
# the same directory as the CMakeLists.txt which builds them
add_subdirectory(src)

if (MSVC)
    set(INSTALL_SCRIPT "install.bat")
else()
    set(INSTALL_SCRIPT "install.sh")
endif()

file(GLOB PROTO_FILES ${CMAKE_PREFIX_PATH}/include/google/protobuf/*.proto)
file(COPY ${PROTO_FILES} DESTINATION ${CMAKE_SOURCE_DIR}/proto/google/protobuf/)

if(NOT QMOD)
    # Minimum build/install move q-script to $QHOME
    file(TO_CMAKE_PATH "$ENV{QHOME}" QHOME_PATH)
    install(DIRECTORY "q/" DESTINATION "${QHOME_PATH}" CONFIGURATIONS MinSizeRel Release FILES_MATCHING PATTERN "*.q")

    set(MY_PRE_MOD_LIBRARY_NAME protobufkdb)

    # Add the copied files to the install package
    file(COPY README.md LICENSE DESTINATION ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/)
    file(COPY examples/ DESTINATION ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/examples/)
    file(COPY q/init.q DESTINATION ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/q/)
    file(RENAME ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/q/init.q "${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/q/${MY_PRE_MOD_LIBRARY_NAME}.q")
    file(COPY proto/ DESTINATION ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/proto/)

    # Copy the .proto files from the protobuf include directory to the install package
    file(COPY ${PROTO_FILES} DESTINATION ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/proto/google/protobuf/)
endif()
