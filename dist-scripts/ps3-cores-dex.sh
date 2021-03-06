#!/bin/sh

make -C ../ -f Makefile.ps3.salamander clean || exit 1
make -C ../ -f Makefile.ps3.rgl clean || exit 1
make -C ../ -f Makefile.ps3 clean || exit 1

make -C ../ -f Makefile.ps3.salamander || exit 1
make -C ../ -f Makefile.ps3.rgl || exit 1

EXE_PATH=/usr/local/cell/host-win32/bin
MAKE_FSELF_NPDRM=$EXE_PATH/make_fself_npdrm.exe
MAKE_PACKAGE_NPDRM=$EXE_PATH/make_package_npdrm.exe

for f in *_ps3.a ; do
   name=`echo "$f" | sed 's/\(_libretro_ps3\|\).a$//'`
   whole_archive=
   if [ $name = "nxengine" ] ; then
      echo "NXEngine found, applying whole archive linking..."
      whole_archive="WHOLE_ARCHIVE_LINK=1"
      echo $name yes
   fi
   if [ $name = "tyrquake" ] ; then
      echo "Tyrquake found, applying big stack..."
      big_stack="BIG_STACK=1"
   fi
   cp -f "$f" ../libretro_ps3.a
   make -C ../ -f Makefile.ps3 $whole_archive $big_stack -j3 || exit 1
   $MAKE_FSELF_NPDRM ../retroarch_ps3.elf ../CORE.SELF
   mv -f ../CORE.SELF ../ps3/pkg/USRDIR/cores/"${name}_libretro_ps3.SELF"
   rm -f ../retroarch_ps3.elf ../retroarch_ps3.self ../CORE.SELF
done

cp -r ../media/rmenu/*.png ../ps3/pkg/USRDIR/cores/borders/Menu/

make -C ../ -f Makefile.griffin platform=ps3 shaders-deploy

$MAKE_FSELF_NPDRM ../retroarch-salamander_ps3.elf ../ps3/pkg/USRDIR/EBOOT.BIN
rm -rf ../retroarch-salamander_ps3.elf
$MAKE_PACKAGE_NPDRM ../ps3/pkg/package.conf ../ps3/pkg
