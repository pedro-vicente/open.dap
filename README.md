# open.dap

Build libdap4 from dependency sources

## Overview

This project provides a complete build system for libdap4 and all its dependencies from source code. It includes automated scripts and detailed instructions for building on multiple platforms, with specific support for Windows.

## Getting Started

For complete build instructions and dependency information, see:

**[libdap4/README.cmake.dependencies.md](libdap4/README.cmake.dependencies.md)**

## Quick Start

The build process involves compiling these dependencies in order:
1. zlib
2. libxml2  
3. curl
4. cppunit
5. libdap4

Each dependency can be built using the provided CMake scripts or the automated build scripts included in this repository.

## License

This project is licensed under the GNU Lesser General Public License v2.1 - see the [LICENSE](LICENSE) file for details.