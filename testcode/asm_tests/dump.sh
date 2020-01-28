#!/bin/bash
ASM_FNAME=$(echo $1 | cut -f 1 -d '.')
arm-linux-gnueabihf-gcc -c "$1" && \
arm-linux-gnueabihf-objdump -d $ASM_FNAME.o | \
tail -n +7 > $ASM_FNAME.dump && \
rm $ASM_FNAME.o