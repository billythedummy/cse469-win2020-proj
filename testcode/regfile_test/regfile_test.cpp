#include <verilated.h>          // Defines common routines
#include "Vregfile.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vregfile *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

int main(int argc, char** argv)
{
    // turn on trace or not?
    bool vcdTrace = true;
    VerilatedVcdC* tfp = NULL;

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new Vregfile;   // Create instance

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
    for (int i = 0; i < 17; ++i) //gotta add +1 for the last eval, *2 just to make sure order of sel++ and eval() dont affect
    {
        /* PUT TEST CODE HERE */

	    /* PUT TEST CODE HERE */
        uut->eval();
        uut->clk = !(uut->clk);
        if (tfp != NULL)
        {
            tfp->dump (main_time);
        }
        main_time++;            // Time passes...
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
