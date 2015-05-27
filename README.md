# sel4-build
This is part of the [sel4-helloworld](https://github.com/winksaville/sel4-helloworld) project
and you also need to follow the instructions at [sel4-manifest](https://github.com/winksaville/sel4-helloworld-manifest).

Currently to add another project at a minimum you need to modify
[Kconfig](https://github.com/winksaville/sel4-build/blob/master/Kconfig) in this project and probably
[default.xml](https://github.com/winksaville/sel4-helloworld-manifest/blob/master/default.xml)
in sel4-helloworld-manifest.

What you should be able to do is just add a new prlect to apps/ and then
"make menuconfig" and "make" should just work! Someday, maybe but I suspect
seL4 may want to do something like Android [Blueprint](https://github.com/google/blueprint)
project for better build control.
