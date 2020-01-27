#include <verilated.h>          // Defines common routines
#include "Vcondchecker.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vcondchecker *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

// main time pre-increment: note convention should be followed for rest of file
void iterateCpsr(Vcondchecker* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    uut->cpsrin = 0;
    for (int i = 0; i < 16; ++i) {
        *main_time = *main_time + 1;
        uut->eval();
        if (tfp != NULL) {
            tfp->dump (*main_time);
        }
        uut->cpsrin++;
    }
}

int main(int argc, char** argv)
{
    // turn on trace or not?
    bool vcdTrace = true;
    VerilatedVcdC* tfp = NULL;

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new Vcondchecker;   // Create instance

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
    
    // Z, C, N, V
    
    // Check Always 1110
    uut->codein = 0b1110;
    iterateCpsr(uut, tfp, &main_time);

    // Check Equal - should only execute if Z is set
    uut->codein = 0b0000;
    iterateCpsr(uut, tfp, &main_time);

    // Check Not Equal - should only execute if Z is not set
    uut->codein = 0b0001;
    iterateCpsr(uut, tfp, &main_time);

    // Check Carry set/ unsigned higher - should only execute if C is set
    uut->codein = 0b0010;
    iterateCpsr(uut, tfp, &main_time);

    // Check ... - should only execute if C is clear
    uut->codein = 0b0011;
    iterateCpsr(uut, tfp, &main_time);

    // Check ... - should only execute if N is set
    uut->codein = 0b0100;
    iterateCpsr(uut, tfp, &main_time);

    // Check ... - should only execute if N is clear
    uut->codein = 0b0101;
    iterateCpsr(uut, tfp, &main_time);

    // Check ... - should only execute if V is set
    uut->codein = 0b0110;
    iterateCpsr(uut, tfp, &main_time);

    // Check ... - should only execute if V is clear
    uut->codein = 0b0111;
    iterateCpsr(uut, tfp, &main_time);

    // Check ... - should only execute if Z clear and C set
    uut->codein = 0b1000;
    iterateCpsr(uut, tfp, &main_time);

    // Should only execute if Z set or C clear
    uut->codein = 0b1001;
    iterateCpsr(uut, tfp, &main_time);

    // Should only execute if (N set and V set) or (N clear and V clear)
    uut->codein = 0b1010;
    iterateCpsr(uut, tfp, &main_time);

    // Should only execute if (N set and V clear) or (N clear and V set)
    uut->codein = 0b1011;
    iterateCpsr(uut, tfp, &main_time);

    // Should only execute if Z clear and ( (N set and V set) or (N clear and V clear) )
    uut->codein = 0b1100;
    iterateCpsr(uut, tfp, &main_time);

    // Should only execute if Z set or (N set and V clear) or (N clear and V set)
    uut->codein = 0b1101;
    iterateCpsr(uut, tfp, &main_time);
    
    // one more so last one is visible
    main_time++;
    uut->eval();
    if (tfp != NULL) {
        tfp->dump (main_time);
    }
    uut->final();               // Done simulating

    if (tfp != NULL)
    {
        tfp->close();
        delete tfp;
    }

    delete uut;

    return 0;
}

