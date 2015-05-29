#!/bin/bash
#
# This creates a new application from apps/helloworld.
# The parameter to the script is the name of the app
# and its directory.

# Create lowercase, uppercase and first character uppercase of the first parameter
lc="${1,,}"
uc="${lc^^}"
fcuc="${lc^}"

if [ "$#" -ne 1 ]; then
  echo ""
  echo "Usage:"
  echo "  ./newapp.sh xxx"
  echo ""
  echo "'xxx' is the name of the new application"
  exit
fi

# Copy helloworld to the new apps directory and rename the config
mkdir apps/${lc}
cp -r apps/helloworld/* apps/${lc}
mv apps/${lc}/master-configs/ia32_simulation_helloworld_defconfig apps/${lc}/master-configs/ia32_simulation_${lc}_defconfig

# Change the contents of Kconfig and Kbuild in the new app
sed -i -e "s/helloworld/${lc}/g" apps/${lc}/K*
sed -i -e "s/HELLOWORLD/${uc}/g" apps/${lc}/K* apps/${lc}/master-configs/ia32_simulation_${lc}_defconfig
sed -i -e "s/Hello World application/${fcuc} application/g" apps/${lc}/Kconfig

# Add the new app to Kconfig .build/ which is symbolicly linked to from the root
sed -i -e "s/.*seL4 Applications.*/&\n    source \"apps\/${lc}\/Kconfig\"/" .build/Kconfig

# Add the new app to Makefile .build/ which is symbolicly linked to from the root
# Note hack for adding a "\" where the eOl's are, I couldn't make anything else work!
sed -i -e "s/^.PHONY.*/simulate-${lc}-ia32:\n\tqemu-system-i386 \\\ -eOl-\n\t\t-m 512 -nographic -kernel images\/kernel-ia32-pc99 \\\ -eOl-\n\t\t-initrd images\/${lc}-image-ia32-pc99\n\n&/" .build/Makefile
sed -i -e "s/ -eOl-//g" .build/Makefile

# Have configs point to the newapp
rm configs
ln -s apps/${lc}/master-configs configs

# Set the default config and make it and run it
make ia32_simulation_${lc}_defconfig
make

echo ""
echo "---------------------------------------------------------------"
echo "Assuming no errors we just configured and made ${lc} app doing:"
echo " make ia32_simulation_${lc}_defconfig"
echo " make"
echo ""
echo "To simulate using qemu:"
echo " make simulate-${lc}-ia32"
echo ""
echo "And to end the qemu simulation type:"
echo " ctrl-a c q"
echo "---------------------------------------------------------------"
