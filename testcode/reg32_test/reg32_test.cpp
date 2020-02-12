#include <verilated.h>          // Defines common routines
#include "Vreg32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vreg32 *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

void vcdStep(Vreg32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    uut->clk = !(uut->clk);
    *main_time = *main_time + 1;
    uut->eval();
    if (tfp != NULL) {
        tfp->dump (*main_time);
    }
}

void fullClock(Vreg32* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
    for (int i = 0; i < 2; ++i) {
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
    uut = new Vreg32;   // Create instance

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
    uut->clk = 0;
    
    // check in1 writing and reading
    int write_data;
    write_data = 0xCAFEF00D;
    uut->we = 1;
    uut->wa = 6;
    uut->wd = write_data;
    fullClock(uut, tfp, &main_time);

    // check if CAFEF00D is stored
    uut->in1 = uut->wa;
    uut->in2 = 9;
    uut->we = 0;
    uut->wa = 0;
    uut->wd = 0;
    fullClock(uut, tfp, &main_time);
    assert(uut->out1 == write_data);
    assert(uut->out2 == 0); // havent written anything to addr 9 yet, should be 0

    // check in2 writing and reading
    write_data = 0xDEADBEEF;
    uut->we = 1;
    uut->wa = 9;
    uut->wd = write_data;
    fullClock(uut, tfp, &main_time);

    // DEADBEEF should be at out2, CAFEF00D should be at out1
    uut->we = 0;
    uut->wa = 0;
    uut->wd = 0;
    fullClock(uut, tfp, &main_time);
    assert(uut->out2 == write_data);

    // to see the rest
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

