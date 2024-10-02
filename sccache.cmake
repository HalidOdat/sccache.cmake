cmake_minimum_required(VERSION 3.20)

include(FetchContent)

set(SCCACHE_ sccache)
set(SCCACHE_VERSION "0.8.2")
set(SCCACHE_HASHSUM "")
set(SCCACHE_DOWNLOAD_URL_BASE "https://github.com/mozilla/sccache/releases/download")
set(SCCACHE_TAG_NAME "v${SCCACHE_VERSION}")
set(SCCACHE_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
set(SCCACHE_EXECUTABLE_EXTENSION "")

# Map cmake host system architecture to sccache release file names.
# TODO: Account for more possible values,
#       see: https://cmake.org/cmake/help/latest/variable/CMAKE_HOST_SYSTEM_NAME.html
#       see: https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html
string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" SCCACHE_RAW_OS)
if (SCCACHE_RAW_OS STREQUAL "windows")
    set(SCCACHE_OS "pc-windows-msvc")
    set(SCCACHE_URL_FILE_EXTENSION "zip")

    # Windows appends the .exe to all executables
    set(SCCACHE_EXECUTABLE_EXTENSION ".exe")
elseif(SCCACHE_RAW_OS STREQUAL "linux")
    set(SCCACHE_OS "unknown-linux-musl")
    set(SCCACHE_URL_FILE_EXTENSION "tar.gz")
elseif(SCCACHE_RAW_OS STREQUAL "darwin")
    set(SCCACHE_OS "apple-darwin")
    set(SCCACHE_URL_FILE_EXTENSION "tar.gz")
endif()
set(SCCACHE_EXECUTABLE_NAME "sccache${SCCACHE_EXECUTABLE_EXTENSION}")

set(SCCACHE_DOWNLOAD_URL "${SCCACHE_DOWNLOAD_URL_BASE}/${SCCACHE_TAG_NAME}/sccache-${SCCACHE_TAG_NAME}-${SCCACHE_ARCH}-${SCCACHE_OS}.${SCCACHE_URL_FILE_EXTENSION}")

message(STATUS "Fetching sccache executable (${SCCACHE_TAG_NAME} ${SCCACHE_ARCH} ${SCCACHE_RAW_OS})...")

# TODO: Use file(DOWNLOAD ...) here so we don't fatal error if FetchContent fails.
# file(DOWNLOAD "${SCCACHE_DOWNLOAD_URL}" "${CMAKE_BINARY_DIR}/sscache.${SCCACHE_URL_FILE_EXTENSION}")
FetchContent_declare(${SCCACHE_}
    URL "${SCCACHE_DOWNLOAD_URL}"
    DOWNLOAD_EXTRACT_TIMESTAMP true
)
FetchContent_MakeAvailable(${SCCACHE_})

# Check if the content was successfully fetched
if(NOT EXISTS ${${SCCACHE_}_SOURCE_DIR})
  message(WARNING "Failed to fetch sccache... using regular builds")
  return()
endif()

cmake_path(APPEND SCCACHE_EXECUTABLE_PATH "${${SCCACHE_}_SOURCE_DIR}" "${SCCACHE_EXECUTABLE_NAME}")
# cmake_path(ABSOLUTE_PATH SCCACHE_EXECUTABLE_PATH "${SCCACHE_EXECUTABLE_PATH}")
message(STATUS "Setting sccache executable path: ${SCCACHE_EXECUTABLE_PATH}")

# find_program(SCCACHE sccache REQUIRED)
# SCCACHE_ERROR_LOG=/tmp/sccache_log.txt SCCACHE_LOG=debug sccache

set(ENV{RUSTC_WRAPPER} "${SCCACHE_EXECUTABLE_PATH}")
set(CMAKE_C_COMPILER_LAUNCHER ${SCCACHE_EXECUTABLE_PATH})
set(CMAKE_CXX_COMPILER_LAUNCHER ${SCCACHE_EXECUTABLE_PATH})
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT Embedded)
cmake_policy(SET CMP0141 NEW)

set(ENV{SCCACHE_CACHE_SIZE} "100G")
set(ENV{SCCACHE_DIRECT} "true")