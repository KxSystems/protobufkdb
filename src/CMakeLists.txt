# ### GENERATE PROTO FILES ###
#
# List the names of the .proto files to be compiled using protoc as a
# CMake argument list (space separated and not wrapped in a string)
#
# Note:  A limitation of cmake protobuf support is that the .proto files
# must be in the same directory as the CMakeLists.txt which builds them
#
# For example to generate 'test.proto':
set(MY_PROTO_FILES tests.proto examples.proto)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE MinSizeRel)
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -DKXVER=3")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_VERBOSE_MAKEFILE ON)

set(MY_LIBRARY_NAME protobufkdb)
file(GLOB SRC_FILES *.cpp)
set_source_files_properties(${SRC_FILES} PROPERTIES LANGUAGE CXX)

message(STATUS "Generator : ${CMAKE_GENERATOR}")
message(STATUS "Build Tool : ${CMAKE_BUILD_TOOL}")
message(STATUS "Proto files: ${MY_PROTO_FILES}")

include_directories (
    $ENV{BUILD_HOME}/include 
    ${CMAKE_BINARY_DIR} # For 'k.h', downloaded below
)

set(Protobuf_USE_STATIC_LIBS ON)
find_package(Protobuf REQUIRED)
include_directories(${PROTOBUF_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Generate the list of .proto files in $MY_PROTO_FILES
PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS ${MY_PROTO_FILES})

# Also generate kdb_type_specifier.proto to get the kdb field option extensions
PROTOBUF_GENERATE_CPP(PROTO_KDB_SRCS PROTO_KDB_HDRS kdb_type_specifier.proto)

# Amalgamate the two sets of generated proto cpp and headers
set(PROTO_SRCS "${PROTO_SRCS};${PROTO_KDB_SRCS}")
set(PROTO_HDRS "${PROTO_HDRS};${PROTO_KDB_HDRS}")

file(DOWNLOAD "https://github.com/KxSystems/kdb/raw/master/c/c/k.h" "${CMAKE_BINARY_DIR}/k.h" )

if (MSVC)
    set(INSTALL_SCRIPT "install.bat")
    file(DOWNLOAD "https://github.com/KxSystems/kdb/raw/master/w64/q.lib" "${CMAKE_BINARY_DIR}/q.lib" )
    set(LINK_LIBS "${CMAKE_BINARY_DIR}/q.lib")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /D WIN32_LEAN_AND_MEAN /D _CRT_SECURE_NO_WARNINGS /D QPROTOBUF_EXPORTS") 
else()
    set(INSTALL_SCRIPT "install.sh")
    set(LINK_LIBS "")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wno-strict-aliasing")
endif()
    
add_library (${MY_LIBRARY_NAME} SHARED ${SRC_FILES} ${PROTO_SRCS} ${PROTO_HDRS})

IF(APPLE)
    set_target_properties(${MY_LIBRARY_NAME} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
    set_target_properties(${MY_LIBRARY_NAME} PROPERTIES SUFFIX .so)
    set(OSFLAG m)
elseif(WIN32)
    set(OSFLAG w)
else()
    set(OSFLAG l)
endif()

target_link_libraries(${MY_LIBRARY_NAME} ${PROTOBUF_LIBRARIES} ${LINK_LIBS})
set_target_properties(${MY_LIBRARY_NAME} PROPERTIES PREFIX "")

# Check if 32-bit/64-bit machine
set(BITNESS 32)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(BITNESS 64)
endif()

# Minimum build/install move binary to $QHOME/<QARCH>
file(TO_CMAKE_PATH "$ENV{QHOME}" QHOME_PATH)
install(TARGETS ${MY_LIBRARY_NAME} DESTINATION "${QHOME_PATH}/${OSFLAG}${BITNESS}/" CONFIGURATIONS MinSizeRel Release)

# Don't really need an install package...
install(TARGETS ${MY_LIBRARY_NAME} DESTINATION ${PROJECT_BINARY_DIR}/install/lib CONFIGURATIONS Release)