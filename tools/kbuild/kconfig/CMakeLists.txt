add_executable(conf conf.c zconf.tab.c)

set(CMAKE_C_FLAGS "-Wall -DCURSES_LOC=\"<ncurses.h>\" -I${CMAKE_CURRENT_SOURCE_DIR} -DLOCALE")
set(CMAKE_EXE_LINKER_FLAGS)
