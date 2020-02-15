#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <VERILOG-FILE> | all"
  exit 1
fi
PROJDIR=$(dirname "$0")
if [ $1 == "all" ]; then
    ls $PROJDIR/cpu | xargs verilator --lint-only -I$PROJDIR/cpu
else
    verilator --lint-only -I$PROJDIR/cpu $1
fi