# CSE 469 COMPUTER ARCHITECTURE I WIN 2020 HARDWARE PROJECT
5 Stage RISC processor on the TinyFPGA BX using ARM32 instruction set.

## Testing with Verilator
How to test individual modules on Linux with `verilator` and `gtkwave`
1. Make a `$MODULE_test` folder in `testcode/`
2. Write a `Makefile` to compile module to be tested
3. Write the test in `$MODULE_test.cpp`. Make sure test terminates or `testmod.sh` will not be able to end and open `gtkwave` properly
4. Call `./testmod.sh $MODULE` this will compile `$MODULE` in `testcode/$MODULE_test/obj_dir/` into cpp with `verilator`, then compile `$MODULE_test.cpp` into an executable `V$MODULE`, run the executable and dump the output to a vcd file `V$MODULE.vcd` (make sure to have `vcdTrace` enabled), then open the .vcd file with gtkwave