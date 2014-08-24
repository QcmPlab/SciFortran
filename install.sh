#!/bin/bash

usage(){
    echo "usage:  $0 [intel,intel_debug] [gnu,gnu_debug,ibm: not yet supported ]"
    exit
}

if [ -z $1 ] || [ $1 == "-h" ] && [ $1=="--help"  ];then
    usage
fi

if [ $1 == "gnu" ] || [ $1 == "gnu_debug" ] || [ $1 == "ibm" ];then
    usage
fi

PLAT=$1
WRKDIR=$(pwd)
WRK_INSTALL=$WRKDIR/_install
if [ ! -d $WRK_INSTALL ];then echo "$0: can not find _install directory";exit;fi

print_ARmake(){    
    cd $WRK_INSTALL
    local ROOT=$WRK_INSTALL
    local PLAT=$1
    DIR_TARGET=$WRKDIR/$PLAT
    local BIN_TARGET=$DIR_TARGET/bin
    local LIB_TARGET=$DIR_TARGET/lib
    local INC_TARGET=$DIR_TARGET/include
    local LIB_SCIFOR=$LIB_TARGET/libscifor.a
    local MOD_SCIFOR=$INC_TARGET
    mkdir -pv $DIR_TARGET
    mkdir -pv $BIN_TARGET
    mkdir -pv $LIB_TARGET
    mkdir -pv $INC_TARGET
    
    case $PLAT in
	intel)
	    FC=ifort
	    FFLAGS="-O2 -static-intel"
	    MOPT="-module "
	    MOD_DIR=intel_mods
	    OBJ_DIR=intel_objs
	    ;;
	gnu)
	    FC=gfortran
	    FFLAGS="-O2 -static"
	    MOPT=-J
	    MOD_DIR=gnu_mods
	    OBJ_DIR=gnu_objs
	    ;;
	intel_debug)
	    FC=ifort
	    FFLAGS="-p -O0 -g -debug -fpe0 -traceback -check all,noarg_temp_created -static-intel"
	    MOPT="-module "
	    MOD_DIR=intel_debug_mods
	    OBJ_DIR=intel_debug_objs
	    ;;
	gnu_debug)
	    FC=gfortran
	    FFLAGS="-O0 -p -g -Wall -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace -static"
	    MOPT=-J
	    MOD_DIR=gnu_debug_mods
	    OBJ_DIR=gnu_debug_objs
	    ;;
	ibm)
	    FC=xlf90
	    FFLAGS="-O2 -qarch=qp -qtune=qp"
	    MOPT="-qmoddir="
	    MOD_DIR=ibm_mods
	    OBJ_DIR=ibm_objs
	    ;;
	*)
	    usage
	    ;;
    esac
    
    echo "Compiling library on platform $PLAT:"
    
    cat << EOF > make.inc
FC=$FC
FFLAGS=$FFLAGS
MOPT=$MOPT
PLAT=$PLAT
OBJ_DIR=$ROOT/src/$OBJ_DIR
MOD_DIR=$ROOT/src/$MOD_DIR
LIB_SCIFOR=$LIB_SCIFOR
MOD_SCIFOR=$MOD_SCIFOR
EOF

    cp -fv $WRK_INSTALL/bin/scifor_completion.sh $BIN_TARGET/lib_completion.sh
    cp -fv $WRK_INSTALL/bin/bash_add_lib.sh      $BIN_TARGET/bash_add_lib.sh
}


print_ARmake $PLAT
make all
if [ $? == 0 ];then
    make clean
    mv -vf make.inc $WRKDIR/$PLAT/
fi
cd $WRKDIR
