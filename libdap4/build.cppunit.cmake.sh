#!/bin/bash

# check if ../ext/cppunit-1.15.1 directory exists, if not clone it
if [ ! -d "../ext/cppunit-1.15.1" ]; then
    echo "cppunit-1.15.1 not found in ../ext/, cloning from GitHub..."
    mkdir -p ../ext
    pushd ../ext
    git -c advice.detachedHead=false clone --branch cppunit-1.15.1 --depth 1 https://anongit.freedesktop.org/git/libreoffice/cppunit.git cppunit-1.15.1
    if [ $? -ne 0 ]; then
        echo "Failed to clone with tag cppunit-1.15.1, trying master branch..."
        git clone --depth 1 https://anongit.freedesktop.org/git/libreoffice/cppunit.git cppunit-1.15.1
        if [ $? -ne 0 ]; then
            echo "Failed to clone cppunit repository"
            exit 1
        fi
    fi
    popd
else
    echo "cppunit-1.15.1 already exists in ../ext/"
fi

# check if CMakeLists.txt exists in cppunit, if not create it
if [ ! -f "../ext/cppunit-1.15.1/CMakeLists.txt" ]; then
    echo "Creating CMakeLists.txt for cppunit-1.15.1..."
    cat > "../ext/cppunit-1.15.1/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(cppunit VERSION 1.15.1)

# Options
option(CPPUNIT_BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(CPPUNIT_BUILD_TESTS "Build tests" OFF)

# Set library type
if(CPPUNIT_BUILD_SHARED_LIBS)
    set(CPPUNIT_LIBRARY_TYPE SHARED)
else()
    set(CPPUNIT_LIBRARY_TYPE STATIC)
endif()

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_BINARY_DIR}/include
)

# Configure header - create config directory if needed
file(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/config)

# Create config.h.cmake
file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/config/config.h.cmake
"#ifndef CPPUNIT_CONFIG_H
#define CPPUNIT_CONFIG_H

#define CPPUNIT_HAVE_SSTREAM 1
#define CPPUNIT_HAVE_STRSTREAM 0
#define CPPUNIT_HAVE_CLASS_STRSTREAM 0
#define CPPUNIT_HAVE_FINITE 1
#define CPPUNIT_HAVE_DLFCN_H 1

#ifdef _WIN32
#  define CPPUNIT_DLL_BUILD
#endif

#endif
")

# Configure header
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/config/config.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/include/cppunit/config.h
)

# Source files
file(GLOB_RECURSE CPPUNIT_SOURCES
    "src/cppunit/*.cpp"
)

# Create the library - use 'cppunit' name (lowercase) to match FindCppUnit expectations
add_library(cppunit ${CPPUNIT_LIBRARY_TYPE} ${CPPUNIT_SOURCES})

# Set target properties
set_target_properties(cppunit PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "cppunit"
)

# Include directories for the target
target_include_directories(cppunit
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# Install targets
install(TARGETS cppunit
    EXPORT cppunitTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install headers
install(DIRECTORY include/cppunit
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# Install config header
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/cppunit/config.h
    DESTINATION include/cppunit
)

# Create a traditional FindCppUnit.cmake compatible setup
# Install a cppunit-config.cmake file
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/cppunit-config.cmake
"# CppUnit Config File
get_filename_component(CPPUNIT_CMAKE_DIR \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)
set(CPPUNIT_INCLUDE_DIRS \"\${CPPUNIT_CMAKE_DIR}/../../include\")
set(CPPUNIT_INCLUDE_DIR \"\${CPPUNIT_INCLUDE_DIRS}\")
set(CPPUNIT_LIBRARIES cppunit)
set(CPPUNIT_LIBRARY cppunit)
set(CPPUNIT_FOUND TRUE)

if(NOT TARGET cppunit)
    include(\"\${CPPUNIT_CMAKE_DIR}/cppunitTargets.cmake\")
endif()
")

# Export targets
install(EXPORT cppunitTargets
    FILE cppunitTargets.cmake
    NAMESPACE cppunit::
    DESTINATION lib/cmake/cppunit
)

# Install config file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/cppunit-config.cmake
    DESTINATION lib/cmake/cppunit
)

# Also install pkg-config file for traditional builds
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/cppunit.pc
"prefix=${CMAKE_INSTALL_PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: cppunit
Description: C++ unit testing framework
Version: ${PROJECT_VERSION}
Libs: -L\${libdir} -lcppunit
Cflags: -I\${includedir}
")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/cppunit.pc
    DESTINATION lib/pkgconfig
)
EOF
else
    echo "CMakeLists.txt already exists in cppunit-1.15.1"
fi

# build cppunit
mkdir -p ../build/cppunit-1.15.1
pushd ../build
pushd cppunit-1.15.1
cmake ../../ext/cppunit-1.15.1 \
  -DCMAKE_INSTALL_PREFIX=../../install/cppunit-1.15.1 \
  -DCPPUNIT_BUILD_SHARED_LIBS=OFF \
  --fresh
cmake --build . --config Debug --parallel
cmake --install . --config Debug
popd 
popd