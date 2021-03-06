#
# Copyright 2014, General Dynamics C4 Systems
#
# This software may be distributed and modified according to the terms of
# the GNU General Public License version 2. Note that NO WARRANTY is provided.
# See "LICENSE_GPLv2.txt" for details.
#
# @TAG(GD_GPL)
#

lib-dirs := libs

all: app-images

-include .config

include tools/common/project.mk

# Some example qemu invocations

QEMU := qemu-system-i386
QEMU_FLAGS := -m 512 -nographic

ifeq ("$(KERNEL_IMAGE)", "")
  # Default kernel
  KERNEL_IMAGE := "images/kernel-ia32-pc99"
endif

ifeq ("$(app)", "")
  # Default app
  app := helloworld
endif
APP_IMAGE := "images/$(app)-image-ia32-pc99"

ifeq ("$(QF)", "")
  # Qemu Flags that the user wants to add
  QF :=
endif

# note: this relies on qemu after version 2.0
run:
	$(QEMU) $(QF) $(QEMU_FLAGS) -kernel $(KERNEL_IMAGE) -initrd $(APP_IMAGE)

# Start qemu in stopped mode (-S option) with a defualt TCP port localhost:1234 (-s option)
debug:
	$(QEMU) -s -S $(QF) $(QEMU_FLAGS) -kernel $(KERNEL_IMAGE) -initrd $(APP_IMAGE)

.PHONY: help
help:
	@echo "mimimal hello world program"
	@echo " make menuconfig        - Select build configuration via menus."
	@echo " make <defconfig>       - Apply one of the default configurations. See"
	@echo "                          below for valid configurations."
	@echo " make silentoldconfig   - Update configuration with the defaults of any"
	@echo "                          newly introduced settings."
	@echo " make run {app=xx}      - Where xx is application in apps/ (default=helloworld)"
	@echo " make                   - Build with the current configuration."
	@echo ""
	@echo "Valid default configurations are:"
	@ls -1 configs | sed -e 's/\(.*\)/\t\1/g'
