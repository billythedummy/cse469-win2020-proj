#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <MODULE-NAME>"
  exit 1
fi
PROJDIR=$(dirname "$0")
pushd $PROJDIR/testcode/$1_test && \
make -j8 && \
./obj_dir/V$1 && \
gtkwave ./obj_dir/V$1.vcd