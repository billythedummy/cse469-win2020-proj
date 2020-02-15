#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <ASM_FILE>"
  exit 1
fi

ASM_FNAME=$(echo $1 | sed 's/\.s//')
FBASENAME=$(basename $ASM_FNAME)
arm-linux-gnueabihf-gcc -c "$1" && \
arm-linux-gnueabihf-objdump -d $FBASENAME.o | \
tail -n +7 > $ASM_FNAME.dump && \
rm $FBASENAME.o
echo "Created output $ASM_FNAME.dump"