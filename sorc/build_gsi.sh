#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  export MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

gsitarget=$target
[[ "$target" == wcoss_cray ]] && gsitarget=cray

if [[ "$target" == jet ]]; then
    if [ -f "../modulefiles/gsi/modulefile.ProdGSI.jet" ]; then
        if [ -d gsi.fd/modulefiles ]; then
            cp ../modulefiles/gsi/modulefile.ProdGSI.jet gsi.fd/modulefiles
            cp ../modulefiles/gsi/setCompilerFlags.cmake gsi.fd/cmake/Modules
        fi
    fi
fi    

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

cd gsi.fd/ush/
./build_all_cmake.sh "PRODUCTION" "$cwd/gsi.fd"

exit
