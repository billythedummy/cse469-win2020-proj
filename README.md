# CSE 469 COMPUTER ARCHITECTURE I WIN 2020 HARDWARE PROJECT
5 Stage Pipelined RISC processor on the TinyFPGA BX using ARM32 instruction set.

## Dependencies

### Testing:
1. Verilator - you'll also need a C++ toolchain. This comes with apt package `build-essential` on Ubuntu.
2. gtkwave

### Synthesis and build
1. tinyprog

### Installing Test Dependencies

#### Ubuntu
`sudo apt-get install gtkwave verilator`

#### Mac
See http://macappstore.org/verilator/ and http://gtkwave.sourceforge.net/

## Testing with Verilator and gtkwave 
How to test individual modules on Linux with `verilator` and `gtkwave`
1. Make a `$MODULE_test` folder in `testcode/`
2. Write a `Makefile` to compile module to be tested
3. Write the test in `$MODULE_test.cpp`. Make sure test terminates or `testmod.sh` will not be able to end and open `gtkwave` properly
4. Call `./testmod.sh $MODULE` - this will compile `$MODULE` in `testcode/$MODULE_test/obj_dir/` into cpp with `verilator`, then compile `$MODULE_test.cpp` into an executable `V$MODULE`, run the executable and dump the output to a vcd file `V$MODULE.vcd` (make sure to have `vcdTrace` enabled), then open the .vcd file with gtkwave

## Generating custom ARM ASM
Note: assumes you're using the `arm-linux-gnueabihf` toolchain. Change it to `arm-none-` or whatever you're using in `dump.sh` if you wanna change that.
1. `cd testcode/asm_tests`
2. Write your asm file
3. `./dump.sh <asm file>`
4. This will make a new file `<asm file>.dump` that contains just the code section of the asm file

## Linting
Use `lint.sh all` to lint all files, `lint.sh <module_name>` to lint just one mod.