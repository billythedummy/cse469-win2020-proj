#include <verilated.h>          // Defines common routines
#include "VstageRE.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

#define TEST_SEL_BITS 3
#define TEST_WIDTH 8

VstageRE *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

void fullClock(VstageRE* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
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
    uut = new VstageRE;   // Create instance

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

    uut->stageRE__DOT__registers__DOT__mem[2] = 0xDEADBEEF;

    uut->rn_a_in = 1;
    fullClock(uut, tfp, &main_time);

    uut->optype_in = 0b001;
    uut->rn_a_in = 2;
    fullClock(uut, tfp, &main_time);

    uut->rn_a_in = 1;
    uut->optype_in = 0b000;
    uut->stall_in = 1;
    fullClock(uut, tfp, &main_time);

    uut->stall_in = 0;
    fullClock(uut, tfp, &main_time);

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
