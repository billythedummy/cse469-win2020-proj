#include <verilated.h>          // Defines common routines
#include "Vcpsr32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vcpsr32 *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

void fullClock(Vcpsr32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    for (int i = 0; i < 2; ++i) { // full clock cycle
        uut->clk = !(uut->clk);
        *main_time = *main_time + 1;
        uut->eval();
        tfp->dump (*main_time);
    }
}

int main(int argc, char** argv)
{
    // turn on trace or not?
    bool vcdTrace = true;
    VerilatedVcdC* tfp = NULL;

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new Vcpsr32;   // Create instance

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
    
    uut->clk = 0;
    fullClock(uut, tfp, &main_time);
    uut->should_set_cpsr = 0b0010;
    int cpsrwd = 0b0010;
    uut->cpsrwd = cpsrwd;
    fullClock(uut, tfp, &main_time);

    uut->should_set_cpsr = 0b0000;
    int cpsrwd2 = 0b0000;
    uut->cpsrwd = cpsrwd2;
    fullClock(uut, tfp, &main_time);
    assert( uut->out == (cpsrwd << 28) );

    uut->should_set_cpsr = 0b0010;
    fullClock(uut, tfp, &main_time);

    fullClock(uut, tfp, &main_time);
    assert( uut->out == (cpsrwd2 << 28) );
    fullClock(uut, tfp, &main_time);

    uut->final();               // Done simulating

    if (tfp != NULL)
    {
        tfp->close();
        delete tfp;
    }

    delete uut;

    return 0;
}

