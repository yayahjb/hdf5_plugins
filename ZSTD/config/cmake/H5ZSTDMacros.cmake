#
# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5.  The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the COPYING file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.
#
#-------------------------------------------------------------------------------
macro (EXTERNAL_ZSTD_LIBRARY compress_type libtype)
  if (${libtype} MATCHES "SHARED")
    set (BUILD_EXT_SHARED_LIBS "ON")
  else ()
    set (BUILD_EXT_SHARED_LIBS "OFF")
  endif ()
  if (${compress_type} MATCHES "GIT")
    EXTERNALPROJECT_ADD (ZSTD
        GIT_REPOSITORY ${ZSTD_URL}
        GIT_TAG ${ZSTD_BRANCH}
        SOURCE_SUBDIR "build/cmake"
        INSTALL_COMMAND ""
        CMAKE_ARGS
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_EXT_SHARED_LIBS}
            -DBUILD_TESTING:BOOL=OFF
            -DZSTD_BUILD_PROGRAMS:BOOL=OFF
            -DZSTD_BUILD_SHARED:BOOL=OFF
            -DZSTD_LEGACY_SUPPORT:BOOL=OFF
            -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
            -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
            -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
            -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
            -DCMAKE_PDB_OUTPUT_DIRECTORY:PATH=${CMAKE_PDB_OUTPUT_DIRECTORY}
            -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
            -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
            -DCMAKE_TOOLCHAIN_FILE:STRING=${CMAKE_TOOLCHAIN_FILE}
    )
  elseif (${compress_type} MATCHES "TGZ")
    EXTERNALPROJECT_ADD (ZSTD
        URL ${ZSTD_URL}
        URL_MD5 ""
        SOURCE_SUBDIR "build/cmake"
        INSTALL_COMMAND ""
        CMAKE_ARGS
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_EXT_SHARED_LIBS}
            -DBUILD_TESTING:BOOL=OFF
            -DZSTD_BUILD_PROGRAMS:BOOL=OFF
            -DZSTD_BUILD_SHARED:BOOL=OFF
            -DZSTD_LEGACY_SUPPORT:BOOL=OFF
            -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
            -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
            -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
            -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
            -DCMAKE_PDB_OUTPUT_DIRECTORY:PATH=${CMAKE_PDB_OUTPUT_DIRECTORY}
            -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
            -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
            -DCMAKE_TOOLCHAIN_FILE:STRING=${CMAKE_TOOLCHAIN_FILE}
    )
  endif ()
  externalproject_get_property (ZSTD BINARY_DIR SOURCE_DIR)

  # Create imported target ZSTD
  add_library (zstd ${libtype} IMPORTED)
  set(STATIC_LIBRARY_BASE_NAME zstd)
  if (MSVC OR (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT MINGW))
    set(STATIC_LIBRARY_BASE_NAME zstd_static)
  endif ()
  HDF_IMPORT_SET_LIB_OPTIONS (zstd "${STATIC_LIBRARY_BASE_NAME}" ${libtype} "" "NOPREFIX")
  add_dependencies (zstd ZSTD)

#  include (${BINARY_DIR}/ZSTD-targets.cmake)
  set (ZSTD_LIBRARY "zstd")

  set (ZSTD_INCLUDE_DIR_GEN "${BINARY_DIR}")
  set (ZSTD_INCLUDE_DIR "${SOURCE_DIR}/lib")
  set (ZSTD_FOUND 1)
  set (ZSTD_LIBRARIES ${ZSTD_LIBRARY})
  set (ZSTD_INCLUDE_DIRS ${ZSTD_INCLUDE_DIR_GEN} ${ZSTD_INCLUDE_DIR})
endmacro ()

#-------------------------------------------------------------------------------
macro (PACKAGE_ZSTD_LIBRARY compress_type)
  add_custom_target (ZSTD-GenHeader-Copy ALL
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${ZSTD_INCLUDE_DIR}/zstd.h ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/
      COMMENT "Copying ${ZSTD_INCLUDE_DIR}/zstd.h to ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/"
  )
  set (EXTERNAL_HEADER_LIST ${EXTERNAL_HEADER_LIST} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/zstd.h)
  if (${compress_type} MATCHES "GIT" OR ${compress_type} MATCHES "TGZ")
    add_dependencies (ZSTD-GenHeader-Copy zstd)
  endif ()
endmacro ()