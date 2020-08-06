cmake_minimum_required(VERSION 3.1.3)
project(protobufkdb CXX)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

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
install(FILES README.md LICENSE ${INSTALL_SCRIPT} DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME}/ CONFIGURATIONS Release)
install(DIRECTORY examples DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME} CONFIGURATIONS Release)
install(DIRECTORY q DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME} CONFIGURATIONS Release)
install(DIRECTORY proto DESTINATION ${PROJECT_BINARY_DIR}/${MY_LIBRARY_NAME} CONFIGURATIONS Release)

