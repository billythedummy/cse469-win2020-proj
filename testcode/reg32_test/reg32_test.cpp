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
    uut->clk = 1;
    
    // check in1 writing and reading
    vcdStep(uut, tfp, &main_time);
    uut->we = 1;
    uut->wa = 6;
    uut->wd = 0xCAFEF00D;
    vcdStep(uut, tfp, &main_time);

    // check if CAFEF00D is stored
    vcdStep(uut, tfp, &main_time);
    uut->in1 = uut->wa;
    uut->in2 = 9;
    uut->we = 0;
    vcdStep(uut, tfp, &main_time);

    // check in2 writing and reading
    vcdStep(uut, tfp, &main_time);
    uut->we = 1;
    uut->wa = 9;
    uut->wd = 0xDEADBEEF;
    vcdStep(uut, tfp, &main_time);

    // DEADBEEF should be at out2, CAFEF00D should be at out1
    vcdStep(uut, tfp, &main_time);
    uut->we = 0;
    vcdStep(uut, tfp, &main_time);

    // Check branching
    vcdStep(uut, tfp, &main_time);
    uut->ib = 1;
    uut->bv = 16;
    vcdStep(uut, tfp, &main_time);

    vcdStep(uut, tfp, &main_time);
    uut->ib = 0;
    vcdStep(uut, tfp, &main_time);

    // Negative branch value
    vcdStep(uut, tfp, &main_time);
    uut->ib = 1;
    uut->bv = -8;
    vcdStep(uut, tfp, &main_time);

    vcdStep(uut, tfp, &main_time);
    uut->ib = 0;
    vcdStep(uut, tfp, &main_time);

    // Overwrite PC
    vcdStep(uut, tfp, &main_time);
    uut->we = 1;
    uut->wa = 15;
    uut->wd = 0xFACEBADE;
    vcdStep(uut, tfp, &main_time);

    vcdStep(uut, tfp, &main_time);
    uut->ib = 0;
    vcdStep(uut, tfp, &main_time);


    // to see the rest
    vcdStep(uut, tfp, &main_time);
    vcdStep(uut, tfp, &main_time);

    vcdStep(uut, tfp, &main_time);
    
    uut->final();               // Done simulating

    if (tfp != NULL)
    {
        tfp->close();
        delete tfp;
    }

    delete uut;

    return 0;
}

