cmake_minimum_required(VERSION 3.14)
project(live_communication_assistant LANGUAGES CXX)

set(BINARY_NAME "live_communication_assistant")

cmake_policy(SET CMP0079 NEW)

# Flutter Windows configuration
include(flutter/generated_plugins.cmake)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Application executable target
add_executable(${BINARY_NAME} WIN32
  "runner/main.cpp"
  "runner/utils.cpp"
  "runner/win32_window.cpp"
  "runner/flutter_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "_HAS_EXCEPTIONS=0")
target_compile_definitions(${BINARY_NAME} PRIVATE UNICODE _UNICODE)
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE ${PLUGIN_BUNDLED_LIBRARIES})
