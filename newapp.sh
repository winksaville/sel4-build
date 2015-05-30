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
  echo "and it will be converted to lower case."
  exit
fi

# Copy helloworld to the new apps directory and rename the config
mkdir apps/${lc}
cp -r apps/helloworld/* apps/${lc}

# Change the contents of Kconfig and Kbuild in the new app
sed -i -e "s/helloworld/${lc}/g" apps/${lc}/K*
sed -i -e "s/HELLOWORLD/${uc}/g" apps/${lc}/K*
sed -i -e "s/Hello World application/${fcuc} application/g" apps/${lc}/Kconfig

# Add the new app to .build/Kconfig which is symbolicly linked to from the root
sed -i -e "s/.*seL4 Applications.*/&\n    source \"apps\/${lc}\/Kconfig\"/" .build/Kconfig

# Add the new app to .build/Makefile which is symbolicly linked to from the root
# Note hack for adding a "\" where the eOl's are, I couldn't make anything else work!
sed -i -e "s/^.PHONY.*/simulate-${lc}-ia32:\n\tqemu-system-i386 \\\ -eOl-\n\t\t-m 512 -nographic -kernel images\/kernel-ia32-pc99 \\\ -eOl-\n\t\t-initrd images\/${lc}-image-ia32-pc99\n\n&/" .build/Makefile
sed -i -e "s/ -eOl-//g" .build/Makefile

# Handle the configurations. We need to do three things
# 1) Rename the files in the destination
# 2) Change any HELLOWORLD's to ${uc}
# 3) Add a symbolic link to each of the configurations in the destination
configurations=(apps/${lc}/master-configs/*)
for file in "${configurations[@]}"; do
  # 1) Rename the files in the destination
  newFile="${file/helloworld/${lc}}"
  echo "file=$file newFile=$newFile"
  if [ "$file" != "$newFile" ]; then
    echo "mv ${file} ${newFile}"
    mv ${file} ${newFile}
  fi

  # 2) Change any HELLOWORLD's to ${uc}
  sed -i -e "s/HELLOWORLD/${uc}/g" $newFile

  # 3) Add a symbolic link to each of the configurations in the destination
  newFilename="${newFile##*/}"
  configsDestFile="configs/$newFilename"
  rm -f $configsDestFile # delete incase it exists
  echo "ln -s ../$newFile $configsDestFile"
  ln -s ../$newFile $configsDestFile
done

echo ""
echo "---------------------------------------------------------------"
echo "Choose a configuration and then make"
echo " make ia32_simulation_${lc}_defconfig"
echo " make"
echo ""
echo "Finally to simulate using qemu:"
echo " make simulate-${lc}-ia32"
echo ""
echo "And to end the qemu simulation type:"
echo " ctrl-a c q"
echo "---------------------------------------------------------------"
