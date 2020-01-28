#include <verilated.h>          // Defines common routines
#include "Videc32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Videc32 *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

void fullClock(Videc32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    for (int i = 0; i < 2; ++i) { // full clock cycle
        uut->clk = !(uut->clk);
        *main_time = *main_time + 1;
        uut->eval();
        tfp->dump (*main_time);
    }
}

void iterateCpsr(Videc32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    uut->cpsrin = 0;
    for (int i = 0; i < 16; ++i) {
        fullClock(uut, tfp, main_time);
        uut->cpsrin++;
    }
}

// PRE INCREMENT

int main(int argc, char** argv)
{
    // turn on trace or not?
    bool vcdTrace = true;
    VerilatedVcdC* tfp = NULL;

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new Videc32;   // Create instance

    uut->eval();
    uut->eval();

    if (vcdTrace)
    {
        Verilated::traceEverOn(true);

        tfp = new VerilatedVcdC;
        uut->trace(tfp, 99);

        std::string vcdname = argv[0];
        vcdname += ".vcd";
        std::cout << vcdname << std::endl;
        tfp->open(vcdname.c_str());
    }

    // Test B
    uut->iin = 0xea00000d; // B 60 | pc = pc + 8 + 4*d = pc + 60
    iterateCpsr(uut, tfp, &main_time); // expect bv to be 52 = 0x34

    // Test BNE
    uut->iin = 0x1a00000c; // B 56 | pc = pc + 8 + 4*c = pc + 56
    iterateCpsr(uut, tfp, &main_time); // expect ib = 0 when not cond, bv to be 48 = 0x30 when !Z 

    // Test BLT
    uut->iin = 0xba00000b; // B 52 | pc = pc + 8 + 4*b = pc + 52
    iterateCpsr(uut, tfp, &main_time); // expect ib = 0 when not cond, bv to be 44 = 0x2c when cond (N != V)

    // Test BL 
    uut->iin = 0xeb00000a; // BL 48 | pc = pc + 8 + 4*a = pc + 48
    iterateCpsr(uut, tfp, &main_time); // bl bit should just be 1. Expect bv to be 40 = 0x28

    // Test ALU ops - all ops should be the same other than registers and opcode
    uut->iin = 0xe1a02001; //mov r2, r1. Rn should be 0
    fullClock(uut, tfp, &main_time);
    uut->iin = 0xe1e03002; //mvn r3, r2. Rn should be 0
    fullClock(uut, tfp, &main_time);
    uut->iin = 0xe0855004; //add r5, r5, r4. Rd = Rn = r5,
    fullClock(uut, tfp, &main_time);
    uut->iin = 0xe0466005; //sub r6, r6, r5. Rd = Rn = r6,
    fullClock(uut, tfp, &main_time);
    uut->iin = 0xe1570006; //cmp r7, r6. Rn=7 Rd should be 0
    fullClock(uut, tfp, &main_time);
    uut->iin = 0xe1180007; //tst r8, r7. Rn=8 Rd should be 0
    fullClock(uut, tfp, &main_time);
    uut->iin = 0xe1390008; //teq r9, r8. Rn=9 Rd should be 0
    fullClock(uut, tfp, &main_time); 
    uut->iin = 0xe0200009; //eor r0, r0, r9. Rd = Rn = r0
    fullClock(uut, tfp, &main_time); 
    uut->iin = 0xe1c11000; //bic r1, r1, r0. Rd = Rn = r1   
    fullClock(uut, tfp, &main_time); 
    uut->iin = 0xe1822001; //orr r2, r2, r1. Rd = Rn = r2
    fullClock(uut, tfp, &main_time); 

    // Test Load
    uut->iin = 0xe5934000; //ldr r4, [r3] // Rd = 4, Rn=3
    fullClock(uut, tfp, &main_time);
    
    // one more so last one is visible
    main_time++;
    uut->eval();
    tfp->dump (main_time);

    uut->final();               // Done simulating

    if (tfp != NULL)
    {
        tfp->close();
        delete tfp;
    }

    delete uut;

    return 0;
}

