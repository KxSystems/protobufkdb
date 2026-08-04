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
	set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -DKXVER=3")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

#set(CMAKE_VERBOSE_MAKEFILE ON)

set(MY_LIBRARY_NAME "clib.${A}")
file(GLOB SRC_FILES *.cpp)
set_source_files_properties(${SRC_FILES} PROPERTIES LANGUAGE CXX)

message(STATUS "Generator : ${CMAKE_GENERATOR}")
message(STATUS "Build Tool : ${CMAKE_BUILD_TOOL}")
message(STATUS "Proto files: ${MY_PROTO_FILES}")

# When building protobuf from source using cmake it statically links against the MSVC runtime.
# Since we are statically linking againat libprotobuf.lib, we must use the same runtime.
if(MSVC)
  foreach(flag_var
      CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if(${flag_var} MATCHES "/MD")
      string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    endif(${flag_var} MATCHES "/MD")
  endforeach()
endif()

include_directories (
    ${CMAKE_BINARY_DIR} # For 'k.h', downloaded below
)

# travis
if(DEFINED ENV{BUILD_HOME} AND NOT "$ENV{BUILD_HOME}" STREQUAL "")
    include_directories($ENV{BUILD_HOME}/include)
endif()

set(Protobuf_DEBUG ON)
set(Protobuf_USE_STATIC_LIBS ${STATIC_LINK})
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

file(
    DOWNLOAD
    "https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h"
    "${CMAKE_BINARY_DIR}/k.h"
    STATUS download_status
    SHOW_PROGRESS
)

message(STATUS "CMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}")
if(EXISTS "${CMAKE_BINARY_DIR}/k.h")
    message(STATUS "k.h exists")
else()
    message(FATAL_ERROR "k.h missing")
endif()

if (MSVC)
    file(DOWNLOAD "https://github.com/KxSystems/kdb/raw/master/w64/q.lib" "${CMAKE_BINARY_DIR}/q.lib" )
    set(LINK_LIBS "${CMAKE_BINARY_DIR}/q.lib")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /D WIN32_LEAN_AND_MEAN /D _CRT_SECURE_NO_WARNINGS") 
    add_compile_options(/wd4946 /wd4710 /wd5045)
    if (NOT USE_STATIC)
        add_compile_definitions(PROTOBUF_USE_DLLS)
        add_compile_options(/wd4251)
    endif()
else()
    set(LINK_LIBS "")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wno-strict-aliasing")
endif()
    
add_library (${MY_LIBRARY_NAME} SHARED ${SRC_FILES} ${PROTO_SRCS} ${PROTO_HDRS})

if(LINUX)
    target_compile_options(${MY_LIBRARY_NAME} PRIVATE "-fvisibility=hidden")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(${MY_LIBRARY_NAME} PRIVATE
        -g3 -O0 -fprofile-arcs -ftest-coverage -fno-inline
    )

    target_link_options(${MY_LIBRARY_NAME} PRIVATE
        --coverage
    )
endif()

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

if(QMOD)
    install(TARGETS ${MY_LIBRARY_NAME} DESTINATION ${MY_MODULE_NAME})
    install(FILES ${CMAKE_SOURCE_DIR}/q/init.q DESTINATION ${MY_MODULE_NAME})
else()
    # Check if 32-bit/64-bit machine
    set(BITNESS 32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(BITNESS 64)
    endif()

    # Copy built shared object after build instead of during installation
    add_custom_command(TARGET ${MY_LIBRARY_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${MY_LIBRARY_NAME}>" ${PROJECT_BINARY_DIR}/${MY_PRE_MOD_LIBRARY_NAME}/lib/${MY_PRE_MOD_LIBRARY_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
        DEPENDS ${MY_LIBRARY_NAME}
    )

    # Minimum build/install move binary to $QHOME/<QARCH>
    file(TO_CMAKE_PATH "$ENV{QHOME}" QHOME_PATH)
    install(TARGETS ${MY_LIBRARY_NAME} DESTINATION "${QHOME_PATH}/${OSFLAG}${BITNESS}/" CONFIGURATIONS MinSizeRel Release)
endif()
