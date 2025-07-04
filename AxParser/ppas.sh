#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/karthik/Lazarus/GetMessage/libdmessagelib.so
OFS=$IFS
IFS="
"
/usr/bin/ld.bfd -b elf64-x86-64 -m elf_x86_64  -init FPC_SHARED_LIB_START -fini FPC_LIB_EXIT -soname libdmessagelib.so  -shared  -L. -o /home/karthik/Lazarus/GetMessage/libdmessagelib.so -T /home/karthik/Lazarus/GetMessage/link14875.res
if [ $? != 0 ]; then DoExitLink /home/karthik/Lazarus/GetMessage/libdmessagelib.so; fi
IFS=$OFS
