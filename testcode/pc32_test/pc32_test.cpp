#include <verilated.h>          // Defines common routines
#include "Vpc32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vpc32 *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

void halfClock(Vpc32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    uut->clk = !(uut->clk);
    *main_time = *main_time + 1;
    uut->eval();
    tfp->dump (*main_time);
}

void fullClock(Vpc32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    for (int i = 0; i < 2; ++i) {
        halfClock(uut, tfp, main_time);
    }
}

int main(int argc, char** argv)
{
    // turn on trace or not?
    bool vcdTrace = true;
    VerilatedVcdC* tfp = NULL;

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new Vpc32;   // Create instance

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
    
    // PUT INIT CODE HERE
    uut->en = 1;
    uut->clk = 0;
    int branch;
    // Check branching
    uut->ib = 1;
    branch = 16;
    uut->bv = branch;
    fullClock(uut, tfp, &main_time);

    uut->ib = 0;
    uut->bv = 0;
    fullClock(uut, tfp, &main_time);
    assert(uut->iaddrout == branch);

    // Negative branch value
    branch = -8;
    uut->ib = 1;
    uut->bv = branch;
    int old_iaddr = uut->iaddrout + 4; // this is before the pos edge + 4
    fullClock(uut, tfp, &main_time);

    uut->ib = 0;
    uut->bv = 0;
    fullClock(uut, tfp, &main_time);
    assert(uut->iaddrout == old_iaddr + branch);

    // Overwrite PC
    int new_pc = 0xFACEBADE;
    uut->we = 1;
    uut->wd = new_pc;
    fullClock(uut, tfp, &main_time);

    uut->ib = 0;
    uut->we = 0;
    uut->wd = 0x69; // random
    fullClock(uut, tfp, &main_time);
    assert(uut->iaddrout == new_pc);

    // check disable
    uut->en = 0;
    int ctr_old = uut->iaddrout;
    fullClock(uut, tfp, &main_time);
    fullClock(uut, tfp, &main_time);
    assert(uut->iaddrout == ctr_old);

    uut->en = 1;
    fullClock(uut, tfp, &main_time);
    assert(uut->iaddrout == ctr_old + 4);

    // to see the rest
    ctr_old = uut->iaddrout;
    fullClock(uut, tfp, &main_time);
    fullClock(uut, tfp, &main_time);
    assert(uut->iaddrout == ctr_old + 8);
    
    uut->final();               // Done simulating

    if (tfp != NULL)
    {
        tfp->close();
        delete tfp;
    }

    delete uut;

    return 0;
}

