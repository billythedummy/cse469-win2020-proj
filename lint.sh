#!/bin/bash
PROJDIR=$(dirname "$0")
if [ $1 == "all" ]; then
    ls $PROJDIR/cpu | xargs verilator --lint-only -I$PROJDIR/cpu
else
    verilator --lint-only -I$PROJDIR/cpu $1
fi