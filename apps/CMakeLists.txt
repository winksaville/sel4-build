# Add a custom target which is located in ./name/name
function(AddRunTarget name)
    add_custom_target(
	run_${name}
	COMMAND qemu-system-i386 -m 512 -nographic -kernel ${CMAKE_BINARY_DIR}/kernel/kernel-${ARCH}-${PLAT} -initrd ${CMAKE_BINARY_DIR}/apps/${name}/${name}
	USES_TERMINAL
    )
endfunction()

# Get the list of directories and add them to the build
file(GLOB dir_content LIST_DIRECTORIES true "*")

foreach(entry ${dir_content})
    if(IS_DIRECTORY ${entry})
	message("-- apps add ${entry}")
	add_subdirectory(${entry})
    endif()
endforeach(entry)

