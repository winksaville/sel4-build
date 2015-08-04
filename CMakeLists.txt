cmake_minimum_required (VERSION 3.2)

project (sel4-newlibs)

# The "ASM" was required to for the CMAKE_ASM_FLAGS below to be effective
# and cause cmake to actually generate the proper ASM_FLAGS value.
enable_language(C ASM)

# Check for ccache
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif(CCACHE_FOUND)

# ARCH and PLAT form a tuple which are used to define part of the path for
# libraries and includes.

# ARCH is the architecture and must be matched with the appropriate PLAT.
# It maybe either x86 or arm, although arm isn't actually supportted at
# this time.
set(ARCH x86
    CACHE STRING
    "Choose x86 | arm"
)

# PLAT is the platform and must be matched with the appropriate ARCH.
set(PLAT pc99
    CACHE STRING
    "Choose pc99"
)

# The C and ASM FLAGS, for x86 only
set(SEL4_C_ASM_FLAGS
    "-Werror -ggdb -g3 -Wall -nostdinc -std=gnu11 -O2 -D_XOPEN_SOURCE=700 \
    -fno-stack-protector -mno-sse -mno-sse2 -mno-mmx -mno-3dnow -m32 -g \
    -DHAVE_AUTOCONF -DIA32 -DARCH_IA32 -DPLAT_PC99 -DDEBUG -DSEL4_DEBUG_KERNEL -DFASTPATH"
)

# Set the linker flags, for x86 only
set(CMAKE_EXE_LINKER_FLAGS
    "${CMAKE_EXE_LINKER_FLAGS} -Wl,--build-id=none -Wl,-m,elf_i386 -nostdlib -u _seL4_Start -e _seL4_Start"
)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SEL4_C_ASM_FLAGS}")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${SEL4_C_ASM_FLAGS}")

# If the generator is Unix Makefile file kernel should use "$(MAKE)"
# so parallel makes work. Other wise we should use "make" itself.
if(${CMAKE_GENERATOR} MATCHES ".*Unix Makefiles")
    set(kernel-make "$(MAKE)")
else()
    set(kernel-make "make")
endif(${CMAKE_GENERATOR} MATCHES ".*Unix Makefiles")

# Custom command to make kernel.elf and copy to CMAKE_BINARY_DIR
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/kernel/kernel-${ARCH}-${PLAT}
    COMMAND ${kernel-make} kernel_elf
    COMMAND mkdir -p ${CMAKE_BINARY_DIR}/kernel
    COMMAND cp ${CMAKE_SOURCE_DIR}/build/kernel/kernel.elf ${CMAKE_BINARY_DIR}/kernel/kernel-${ARCH}-${PLAT}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

# Custom target to invoke the sel4_kernel custom command
add_custom_target(
    sel4_kernel
    DEPENDS ${CMAKE_BINARY_DIR}/kernel/kernel-${ARCH}-${PLAT}
)


# Look for additional CMakeLists.txt files
add_subdirectory(libs)
add_subdirectory(apps)
add_subdirectory(tools/kbuild/kconfig)
