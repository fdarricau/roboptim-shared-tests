# Copyright 2013, Thomas Moulard, CNRS-AIST JRL.
#
# This file is part of roboptim-core.
# roboptim-core is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# roboptim-core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Lesser Public License for more details.
# You should have received a copy of the GNU Lesser General Public License
# along with roboptim-core.  If not, see <http://www.gnu.org/licenses/>.

# Add Boost path to include directories.
INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIRS})

# Make Boost.Test generates the main function in test cases.
ADD_DEFINITIONS(-DBOOST_TEST_DYN_LINK -DBOOST_TEST_MAIN)

# Add current directory to include directories.
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/shared-tests)

# CHECK_TEST_PARAMETERS()
# -----------------------
#
# Verify that test problem parameters were properly set.
#
MACRO(CHECK_TEST_PARAMETERS)
  IF(SOLVER_NAME)
  ELSE()
    MESSAGE(FATAL_ERROR "require SOLVER_NAME to be set")
  ENDIF()

  IF(PLUGIN_PATH)
  ELSE()
    MESSAGE(FATAL_ERROR "require PLUGIN_PATH to be set")
  ENDIF()

  IF(FUNCTION_TYPE)
  ELSE()
    MESSAGE(FATAL_ERROR "require FUNCTION_TYPE to be set")
  ENDIF()

  IF(COST_FUNCTION_TYPE)
  ELSE()
    MESSAGE(FATAL_ERROR "require COST_FUNCTION_TYPE to be set")
  ENDIF()

  IF(DEFINED CONSTRAINT_TYPE_1)
  ELSE()
    MESSAGE(FATAL_ERROR "require CONSTRAINT_TYPE_1 to be set")
  ENDIF()

  IF(CONSTRAINT_TYPE_1)
    SET(CONSTRAINT_TYPE_1_STR "-DCONSTRAINT_TYPE_1=${CONSTRAINT_TYPE_1}")
  ELSE()
    SET(CONSTRAINT_TYPE_1_STR "")
  ENDIF()

  IF(CONSTRAINT_TYPE_2)
    SET(CONSTRAINT_TYPE_2_STR "-DCONSTRAINT_TYPE_2=${CONSTRAINT_TYPE_2}")
  ELSE()
    SET(CONSTRAINT_TYPE_2_STR "")
  ENDIF()
ENDMACRO()

# BUILD_TEST(FILE_NAME)
# ---------------------
#
# Define a test named `${NAME}${PROGRAM_SUFFIX}' where `${PROGRAM_SUFFIX}' is
# an environment variable (e.g. `-sparse').
#
# This macro will create a binary from `${NAME}.cc', link it
# against Boost and add it to the test suite as `${NAME}${PROGRAM_SUFFIX}'.
#
MACRO(BUILD_TEST FILE_NAME)
  CHECK_TEST_PARAMETERS()

  GET_FILENAME_COMPONENT(EXE_NAME ${FILE_NAME} NAME)
  ADD_EXECUTABLE(${EXE_NAME}${PROGRAM_SUFFIX}
    shared-tests/${FILE_NAME}.cc)

  IF(NOT(MSVC))
    SET_TARGET_PROPERTIES(${EXE_NAME}${PROGRAM_SUFFIX}
      PROPERTIES COMPILE_FLAGS
      "-DSOLVER_NAME='\"${SOLVER_NAME}\"' -DPLUGIN_PATH='\"${PLUGIN_PATH}\"' -DFUNCTION_TYPE=${FUNCTION_TYPE} -DCOST_FUNCTION_TYPE=${COST_FUNCTION_TYPE} ${CONSTRAINT_TYPE_1_STR} ${CONSTRAINT_TYPE_2_STR} -DTESTS_DATA_DIR='\"${CMAKE_CURRENT_SOURCE_DIR}\"' -DLOG_FILENAME='\"${EXE_NAME}${PROGRAM_SUFFIX}.log\"' ")
  ELSE()
    SET_TARGET_PROPERTIES(${EXE_NAME}${PROGRAM_SUFFIX}
      PROPERTIES COMPILE_FLAGS
      "-DSOLVER_NAME#\\\"${SOLVER_NAME}\\\" -DPLUGIN_PATH#\\\"${PLUGIN_PATH}\\\" -DFUNCTION_TYPE#${FUNCTION_TYPE} -DCOST_FUNCTION_TYPE#${COST_FUNCTION_TYPE} ${CONSTRAINT_TYPE_1_STR} ${CONSTRAINT_TYPE_2_STR} -DTESTS_DATA_DIR#\\\"${CMAKE_CURRENT_SOURCE_DIR}\\\" -DLOG_FILENAME#\\\"${EXE_NAME}${PROGRAM_SUFFIX}.log\\\" ")
  ENDIF()

  ADD_TEST(${EXE_NAME}${PROGRAM_SUFFIX}
    ${RUNTIME_OUTPUT_DIRECTORY}/${EXE_NAME}${PROGRAM_SUFFIX})

  PKG_CONFIG_USE_DEPENDENCY(${EXE_NAME}${PROGRAM_SUFFIX} roboptim-core)

  # Link against Boost.
  TARGET_LINK_LIBRARIES(${EXE_NAME}${PROGRAM_SUFFIX} ${Boost_LIBRARIES})

  # Make sure the plugins will be found.
  SET_PROPERTY(
    TEST ${EXE_NAME}${PROGRAM_SUFFIX} PROPERTY ENVIRONMENT
    "LTDL_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src:$ENV{LTDL_LIBRARY_PATH}")
  SET_PROPERTY(
    TEST ${EXE_NAME}${PROGRAM_SUFFIX} PROPERTY ENVIRONMENT
    "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src:$ENV{LD_LIBRARY_PATH}")
ENDMACRO()

# EXPECT_TEST_FAIL(FILE_NAME)
# -----------------------------
#
# Set WILL_FAIL property for the given test. This can be used to
# validate a test suite even though all tests do not normally succeed.
MACRO(EXPECT_TEST_FAIL FILE_NAME)
  GET_FILENAME_COMPONENT(EXE_NAME ${FILE_NAME} NAME)
  SET_TESTS_PROPERTIES(${EXE_NAME}${PROGRAM_SUFFIX} PROPERTIES WILL_FAIL TRUE)
ENDMACRO()

# BUILD_COMMON_TESTS()
# -------------------------
#
# Build common tests for plugins.
#
MACRO(BUILD_COMMON_TESTS)
  INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/shared-tests/common/CMakeLists.txt)
ENDMACRO()

# BUILD_SCHITTKOWSKI_PROBLEMS()
# -----------------------------
#
# Build Schittkowski problems. ${SCHITTKOWSKI_PROBLEMS} can be set to
# specify Schittkowski problems to build (default = all).
#
MACRO(BUILD_SCHITTKOWSKI_PROBLEMS)
  INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/shared-tests/schittkowski/CMakeLists.txt)
ENDMACRO()

# BUILD_QP_PROBLEMS()
# -------------------------
#
# Build QP problems.
#
MACRO(BUILD_QP_PROBLEMS)
  INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/shared-tests/qp/CMakeLists.txt)
ENDMACRO()

# BUILD_ROBOPTIM_PROBLEMS()
# -------------------------
#
# Build homemade RobOptim problems.
#
MACRO(BUILD_ROBOPTIM_PROBLEMS)
  INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/shared-tests/roboptim/CMakeLists.txt)
ENDMACRO()
