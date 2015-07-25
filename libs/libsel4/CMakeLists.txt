add_library(libsel4 STATIC
    src/sel4_bootinfo.c
)

target_compile_definitions(libsel4
    PUBLIC HAVE_LIBSEL4
)

target_include_directories(libsel4 SYSTEM
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/arch_include/${ARCH}"
    PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include"
    PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/arch_include/${ARCH}"
    PUBLIC "${CMAKE_SOURCE_DIR}/include/generated"
)

# Paths to XML input files for generating headers.
set(SEL4ARCH_XML "${CMAKE_CURRENT_SOURCE_DIR}/arch_include/${ARCH}/interfaces/sel4arch.xml")
set(SEL4_XML "${CMAKE_CURRENT_SOURCE_DIR}/include/interfaces/sel4.xml")
set(SYSCALL_XML "${CMAKE_CURRENT_SOURCE_DIR}/include/api/syscall.xml")

# Custom command to make autoconf.h
# TODO: Change autoconf.h generation to use CMake makefiles
set(AUTOCONF_H_OUTPUT "${CMAKE_SOURCE_DIR}/include/generated/autoconf.h")
add_custom_command(
    OUTPUT  ${AUTOCONF_H_OUTPUT}
    COMMAND $(MAKE) -f ${CMAKE_SOURCE_DIR}/Makefile silentoldconfig
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

# Custom target to invoke the libsel4 custom command
add_custom_target(
    autoconf.h
    DEPENDS ${AUTOCONF_H_OUTPUT}
)

# Custom command to make types_gen.h
set(BF_GEN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tools/bitfield_gen.py")
set(TYPES_GEN_H_OUTPUT_DIR  "${CMAKE_CURRENT_BINARY_DIR}/include/sel4")
set(TYPES_GEN_H_OUTPUT  "${TYPES_GEN_H_OUTPUT_DIR}/types_gen.h")
add_custom_command(
    OUTPUT  ${TYPES_GEN_H_OUTPUT}
    COMMAND mkdir -p ${TYPES_GEN_H_OUTPUT_DIR}
    COMMAND python ${BF_GEN_PATH} --environment libsel4 "${CMAKE_CURRENT_SOURCE_DIR}/include/sel4/types.bf" ${TYPES_GEN_H_OUTPUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Custom target to invoke the types_gen.h custom command
add_custom_target(
    types_gen.h
    DEPENDS ${TYPES_GEN_H_OUTPUT}
)

# Custom command to make sel4_client.h
set(SYSCALL_STUB_GEN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tools/syscall_stub_gen.py")
set(SEL4_CLIENT_H_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/include/interfaces")
set(SEL4_CLIENT_H_OUTPUT "${SEL4_CLIENT_H_OUTPUT_DIR}/sel4_client.h")
add_custom_command(
    OUTPUT  ${SEL4_CLIENT_H_OUTPUT}
    COMMAND mkdir -p ${SEL4_CLIENT_H_OUTPUT_DIR}
    COMMAND python ${SYSCALL_STUB_GEN_PATH} -a ${ARCH} -o ${SEL4_CLIENT_H_OUTPUT} ${SEL4ARCH_XML} ${SEL4_XML}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Custom target to invoke sel4_client.h
add_custom_target(
    sel4_client.h
    DEPENDS ${SEL4_CLIENT_H_OUTPUT}
)

# Custom command to make syscall.h
set(SYSCALL_ID_GEN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tools/syscall_header_gen.py")
set(SYSCALL_H_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/include/sel4")
set(SYSCALL_H_OUTPUT "${SYSCALL_H_OUTPUT_DIR}/syscall.h")
add_custom_command(
    OUTPUT  ${SYSCALL_H_OUTPUT}
    COMMAND mkdir -p ${SYSCALL_H_OUTPUT_DIR}
    COMMAND python ${SYSCALL_ID_GEN_PATH} --xml ${SYSCALL_XML} --libsel4_header ${SYSCALL_H_OUTPUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Custom target to invoke the syscall.h custom command
add_custom_target(
    syscall.h
    DEPENDS ${SYSCALL_H_OUTPUT}
)

# Custom command to make invocation.h
set(INVOCATION_ID_GEN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tools/invocation_header_gen.py")
set(INVOCATION_H_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/include/sel4")
set(INVOCATION_H_OUTPUT "${INVOCATION_H_OUTPUT_DIR}/invocation.h")
add_custom_command(
    OUTPUT  ${INVOCATION_H_OUTPUT}
    COMMAND mkdir -p ${INVOCATION_H_OUTPUT_DIR}
    COMMAND python ${INVOCATION_ID_GEN_PATH} --xml ${SEL4_XML} --libsel4 --dest ${INVOCATION_H_OUTPUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Custom target to invoke the invocation.h custom command
add_custom_target(
    invocation.h
    DEPENDS ${INVOCATION_H_OUTPUT}
)

# Custom command to make arch_invocation.h
set(ARCH_INVOCATION_ID_GEN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tools/invocation_header_gen.py")
set(ARCH_INVOCATION_H_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/arch_include/${ARCH}/sel4/arch")
set(ARCH_INVOCATION_H_OUTPUT "${ARCH_INVOCATION_H_OUTPUT_DIR}/invocation.h")
add_custom_command(
    OUTPUT  ${ARCH_INVOCATION_H_OUTPUT}
    COMMAND mkdir -p ${ARCH_INVOCATION_H_OUTPUT_DIR}
    COMMAND python ${ARCH_INVOCATION_ID_GEN_PATH} --xml ${SEL4ARCH_XML} --libsel4 --arch --dest ${ARCH_INVOCATION_H_OUTPUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Custom target to invoke the arch_invocation.h custom command
add_custom_target(
    arch_invocation.h
    DEPENDS ${ARCH_INVOCATION_H_OUTPUT}
)


add_dependencies(libsel4
    autoconf.h
    sel4_client.h
    types_gen.h
    syscall.h
    invocation.h
    arch_invocation.h
)

