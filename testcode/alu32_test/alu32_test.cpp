#include <verilated.h>          // Defines common routines
#include "Valu32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Valu32 *uut;                     // Instantiation of module
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
    uut = new Valu32;   // Create instance

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
    
    // 
    for (int i = 0; i < 16; ++i) {
        uut->codein = i;
        for (int j = -32; j < 32; ++j) {
            uut->Rn = j;
            for (int k = -32; k < 32; ++k) {
                main_time++;
                uut->shifter = k;
                uut->eval();
                switch (i) {
                    case 0b0000:
                        assert(uut->out == (j & k));
                        break;
                    case 0b0001:
                        assert(uut->out == (j ^ k));
                        break;
                    case 0b0010:
                        assert(uut->out == (j - k));
                        break;
                    case 0b0011:
                        assert(uut->out == (k - j));
                        break;
                    case 0b0100:
                        assert(uut->out == (j + k));
                        break;
                    case 0b1000:
                        assert(uut->out == (j & k));
                        break;
                    case 0b1001:
                        assert(uut->out == (j ^ k));
                        break;
                    case 0b1010:
                        assert(uut->out == (j - k));
                        break;
                    case 0b1011:
                        assert(uut->out == (j + k));
                        break;
                    case 0b1101:
                        assert(uut->out == k);
                        break;
                    case 0b1110:
                        assert(uut->out == (j & ~k));
                        break;
                    case 0b1111:
                        assert(uut->out == ~k);
                        break;
                    default: break;
                }
                unsigned char z = (uut->flagsout) & 0b1;
                unsigned char c = ((uut->flagsout) & 0b10) >> 1;
                unsigned char n = ((uut->flagsout) & 0b100) >> 2;
                unsigned char v = ((uut->flagsout) & 0b1000) >> 3;
                assert(z == (uut->out == 0));
                assert(n == ( ((signed)uut->out) < 0));
            }
        }
    }

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

