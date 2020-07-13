cmake_minimum_required(VERSION 3.1.3)
project(protobufkdb CXX)

# A limitation of cmake protobuf support is that the .proto files must be in 
# the same directory as the CMakeLists.txt which builds them
add_subdirectory(src)

# Check if 32-bit/64-bit machine
set(BITNESS 32)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(BITNESS 64)
endif()

# Minimum build/install move q-script to $QHOME
file(TO_CMAKE_PATH "$ENV{QHOME}" QHOME_PATH)
install(DIRECTORY "q/" DESTINATION "${QHOME_PATH}" CONFIGURATIONS MinSizeRel Release FILES_MATCHING PATTERN "*.q")

# Don't really need an install package...
install(FILES README.md install.bat install.sh LICENSE ${INSTALL_SCRIPT} DESTINATION ${PROJECT_BINARY_DIR}/install/ CONFIGURATIONS Release)
install(DIRECTORY examples DESTINATION ${PROJECT_BINARY_DIR}/install CONFIGURATIONS Release)
install(DIRECTORY q DESTINATION ${PROJECT_BINARY_DIR}/install CONFIGURATIONS Release)
install(DIRECTORY proto DESTINATION ${PROJECT_BINARY_DIR}/install CONFIGURATIONS Release)
