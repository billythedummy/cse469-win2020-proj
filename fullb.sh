#!/bin/bash
# dont forget to hit the reset button!!!
apio build --verbose-nextpnr --verbose-yosys && tinyprog -p hardware.bin
