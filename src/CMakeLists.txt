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
set(Protobuf_DEBUG ON)
set(Protobuf_USE_STATIC_LIBS ${STATIC_LINK})

# Must be a cache entry: protobuf-options.cmake declares this with option(),
# which under CMP0077 OLD clears a normal variable of the same name.
set(protobuf_MODULE_COMPATIBLE TRUE CACHE BOOL "" FORCE)

# The config package is preferred because it is the only thing that exports
# protobuf's Abseil dependency.  Turn this off where CMAKE_PREFIX_PATH points at
# a protobuf that ships no config package and another protobuf is installed
# system-wide, or the config search escapes to the wrong one - e.g. on macOS,
# keg-only protobuf@21 next to Homebrew's keg-linked protobuf in /usr/local.
option(PROTOBUF_PREFER_CONFIG "Use protobuf's CMake config package if present" ON)

if(PROTOBUF_PREFER_CONFIG)
    find_package(Protobuf CONFIG QUIET)
endif()
if(Protobuf_FOUND)
    set(PROTOBUF_CONFIG_MODE TRUE)
    message(STATUS "Found protobuf ${Protobuf_VERSION} (CMake config package)")
else()
    set(PROTOBUF_CONFIG_MODE FALSE)
    find_package(Protobuf MODULE REQUIRED)
    message(STATUS "Found protobuf ${Protobuf_VERSION} (FindProtobuf module)")
endif()

if(NOT COMMAND protobuf_generate_cpp)
    message(FATAL_ERROR "protobuf provided no protobuf_generate_cpp() command")
endif()

# Protobuf_VERSION cannot be compared across releases: 3.21.12 reports
# "3.21.12", v22.0 reports "4.22.0", but from v25 the config package drops the
# major and reports <minor>.<patch>.0 ("36.1.0" for v36.1).  Read
# GOOGLE_PROTOBUF_VERSION from the header instead - the same value
# MessageFactory.h keys its MultiFileErrorCollector override off.
if(TARGET protobuf::libprotobuf)
    get_target_property(PROTOBUF_TARGET_INCLUDE_DIRS
        protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)
endif()

# PATHS + NO_DEFAULT_PATH, not HINTS: find_file searches CMAKE_PREFIX_PATH
# *before* HINTS, so HINTS could read a different protobuf's header than the one
# found above.  Only the include dirs find_package reported are acceptable.
find_file(PROTOBUF_COMMON_H
    NAMES common.h
    PATHS ${PROTOBUF_TARGET_INCLUDE_DIRS} ${Protobuf_INCLUDE_DIRS}
    PATH_SUFFIXES google/protobuf/stubs
    NO_DEFAULT_PATH
)
if(NOT PROTOBUF_COMMON_H)
    message(FATAL_ERROR
        "Could not locate google/protobuf/stubs/common.h under the protobuf "
        "include dirs: ${PROTOBUF_TARGET_INCLUDE_DIRS} ${Protobuf_INCLUDE_DIRS}")
endif()
message(STATUS "Protobuf headers: ${PROTOBUF_COMMON_H}")

file(STRINGS "${PROTOBUF_COMMON_H}" PROTOBUF_VERSION_DEFINE
    REGEX "^#define[ \t]+GOOGLE_PROTOBUF_VERSION[ \t]+[0-9]+")
string(REGEX MATCH "[0-9]+" GOOGLE_PROTOBUF_VERSION "${PROTOBUF_VERSION_DEFINE}")
message(STATUS "GOOGLE_PROTOBUF_VERSION: ${GOOGLE_PROTOBUF_VERSION}")

# Let the sources verify they really are compiling against this protobuf; see
# the #error in MessageFactory.h.
add_definitions(-DKXPB_EXPECTED_PROTOBUF_VERSION=${GOOGLE_PROTOBUF_VERSION})

# FindProtobuf does not export protobuf's Abseil dependency, so linking would
# silently leave the absl symbols in the protoc-generated code undefined.
if(NOT PROTOBUF_CONFIG_MODE AND GOOGLE_PROTOBUF_VERSION GREATER_EQUAL 4022000)
    message(FATAL_ERROR
        "protobuf ${Protobuf_VERSION} was found through the FindProtobuf module, "
        "which cannot supply its Abseil dependency.  Point CMAKE_PREFIX_PATH at "
        "an installation that ships protobuf's CMake config package, or use an "
        "older protobuf.")
endif()

# major * 10^6 + minor * 10^3 + micro, so 4022000 is v22.0, which needs C++14.
# v30.0 needs C++17, as does the cxx17 libabseil that libprotobuf is built
# against, so use C++17 for everything from v22.0 rather than track both floors.
if(GOOGLE_PROTOBUF_VERSION LESS 4022000)
    set(REQUIRED_CXX_STANDARD 11)
else()
    set(REQUIRED_CXX_STANDARD 17)
endif()

if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD ${REQUIRED_CXX_STANDARD})
elseif(CMAKE_CXX_STANDARD LESS REQUIRED_CXX_STANDARD)
    message(STATUS
        "Raising CMAKE_CXX_STANDARD from ${CMAKE_CXX_STANDARD} to "
        "${REQUIRED_CXX_STANDARD}, required by protobuf ${Protobuf_VERSION}")
    set(CMAKE_CXX_STANDARD ${REQUIRED_CXX_STANDARD})
endif()

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
message(STATUS "CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")

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

if(NOT PROTOBUF_INCLUDE_DIRS)
    message(FATAL_ERROR "protobuf was found but reported no include directories")
endif()

# Imported targets contribute their include dirs as -isystem, which is searched
# after every -I *and* alongside the compiler's own system dirs - so on macOS
# /usr/local/include can win over the protobuf CMAKE_PREFIX_PATH points at.
# Keep them as plain -I so the BEFORE below actually puts protobuf first.
set(CMAKE_NO_SYSTEM_FROM_IMPORTED TRUE)
include_directories(BEFORE ${PROTOBUF_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
message(STATUS "Protobuf include dirs: ${PROTOBUF_INCLUDE_DIRS}")
if(DEFINED ENV{BUILD_HOME})
    message(STATUS "BUILD_HOME is set in the environment: $ENV{BUILD_HOME}")
endif()

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

if(TARGET protobuf::libprotobuf)
    target_link_libraries(${MY_LIBRARY_NAME} protobuf::libprotobuf ${LINK_LIBS})
else()
    target_link_libraries(${MY_LIBRARY_NAME} ${PROTOBUF_LIBRARIES} ${LINK_LIBS})
endif()
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
