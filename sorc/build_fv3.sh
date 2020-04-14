#! /usr/bin/env bash
set -eux

set +e
source ./machine-setup.sh > /dev/null 2>&1
set -e
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  export MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

if [ $target = hera ]; then target=hera.intel ; fi

cd fv3gfs.fd/
FV3=$( pwd -P )/FV3
cd tests/
./compile.sh "$FV3" "$target" "WW3=Y 32BIT=Y" 1
mv -f fv3_1.exe ../NEMS/exe/global_fv3gfs.x
