cmake_minimum_required(VERSION 3.1.3)
project(protobufkdb CXX)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

if(NOT CMAKE_PREFIX_PATH)
	message(FATAL_ERROR "CMAKE_PREFIX_PATH must be set to the location of your protobuf installation directory")
endif()

message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")

# A limitation of cmake protobuf support is that the .proto files must be in 
# the same directory as the CMakeLists.txt which builds them
add_subdirectory(src)

set(MY_LIBRARY_NAME protobufkdb)

if (MSVC)
    set(INSTALL_SCRIPT "install.bat")
else()
    set(INSTALL_SCRIPT "install.sh")
endif()

# Minimum build/install move q-script to $QHOME
file(TO_CMAKE_PATH "$ENV{QHOME}" QHOME_PATH)
install(DIRECTORY "q/" DESTINATION "${QHOME_PATH}" CONFIGURATIONS MinSizeRel Release FILES_MATCHING PATTERN "*.q")

# Add the copied files to the install package
file(COPY README.md LICENSE ${INSTALL_SCRIPT} DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME}/)
file(COPY examples/ DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME}/examples/)
file(COPY q/ DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME}/q/)
file(COPY proto/ DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME}/proto/)

# Copy the .proto files from the protobuf include directory to the install package
file(GLOB PROTO_FILES ${CMAKE_PREFIX_PATH}/include/google/protobuf/*.proto)
file(COPY ${PROTO_FILES} DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME}/proto/google/protobuf/)
