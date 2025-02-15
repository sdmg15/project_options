include("${ProjectOptions_SRC_DIR}/Utilities.cmake")

# Run vcvarsall.bat and set CMake environment variables
function(run_vcvarsall)
  # if MSVC but VSCMD_VER is not set, which means vcvarsall has not run
  if(MSVC AND "$ENV{VSCMD_VER}" STREQUAL "")

    # find vcvarsall.bat
    get_filename_component(MSVC_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
    find_file(
      VCVARSALL_FILE
      NAMES vcvarsall.bat
      PATHS "${MSVC_DIR}"
            "${MSVC_DIR}/.."
            "${MSVC_DIR}/../.."
            "${MSVC_DIR}/../../../../../../../.."
            "${MSVC_DIR}/../../../../../../.."
      PATH_SUFFIXES "VC/Auxiliary/Build" "Common7/Tools" "Tools")

    if(EXISTS ${VCVARSALL_FILE})
      # detect the architecture
      detect_architecture(VCVARSALL_ARCH)

      # run vcvarsall and print the environment variables
      message(STATUS "Running `${VCVARSALL_FILE} ${VCVARSALL_ARCH}` to set up the MSVC environment")
      execute_process(
        COMMAND
          "cmd" "/c" ${VCVARSALL_FILE} ${VCVARSALL_ARCH} #
          "&&" "call" "echo" "VCVARSALL_ENV_START" #
          "&" "set" #
        OUTPUT_VARIABLE VCVARSALL_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE)

      # parse the output and get the environment variables string
      find_substring_by_prefix(VCVARSALL_ENV "VCVARSALL_ENV_START" "${VCVARSALL_OUTPUT}")

      # set the environment variables
      set_env_from_string("${VCVARSALL_ENV}")

    else()
      message(
        WARNING
          "Could not find `vcvarsall.bat` for automatic MSVC environment preparation. Please manually open the MSVC command prompt and rebuild the project.
      ")
    endif()
  endif()
endfunction()
