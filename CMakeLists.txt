cmake_minimum_required (VERSION 3.3)

project (sel4-newlibs)

include_directories(SYSTEM stage/x86/pc99/include)

add_custom_command(
    OUTPUT ${CMAKE_SOURCE_DIR}/build/kernel/kernel.elf
    COMMAND make kernel_elf
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

add_custom_target(
    sel4_kernel
    DEPENDS ${CMAKE_SOURCE_DIR}/build/kernel/kernel.elf)


add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/libs/libsel4/libsel4.a
    COMMAND make libsel4
    COMMAND mkdir -p ${CMAKE_BINARY_DIR}/libs/libsel4
    COMMAND cp build/x86/pc99/libsel4/libsel4.a ${CMAKE_BINARY_DIR}/libs/libsel4
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

add_custom_target(
    libsel4
    DEPENDS ${CMAKE_BINARY_DIR}/libs/libsel4/libsel4.a)

add_subdirectory(libs)
add_subdirectory(apps)
