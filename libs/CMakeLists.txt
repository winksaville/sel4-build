file(GLOB dir_content LIST_DIRECTORIES true "*")

foreach(entry ${dir_content})
    if(IS_DIRECTORY ${entry})
	message("-- libs add ${entry}")
	add_subdirectory(${entry})
    endif()
endforeach(entry)
