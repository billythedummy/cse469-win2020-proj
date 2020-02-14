#include <verilated.h>          // Defines common routines
#include "Vshifter32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

#define LIMIT 65536

Vshifter32 *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

int ror(unsigned int n, unsigned int d) 
{ 
    return (n >> d)|(n << (32 - d)); 
} 

int lsr(unsigned int n, unsigned int d)
{
    return n >> d;
}

unsigned int extractBit(unsigned int n, unsigned int i)
{
    unsigned int mask = 1 << i;
    return (n & mask) >> i; // unsigned for logical
}

int main(int argc, char** argv)
{
    // turn on trace or not?
    bool vcdTrace = true;
    VerilatedVcdC* tfp = NULL;

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new Vshifter32;   // Create instance

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

    // test LSL
    uut->shiftcode = 0b00;
    for (int i = 0; i < 32; ++i) {
        uut->shiftby = i;
        for (int j = -LIMIT; j < LIMIT; ++j) {
            uut->shiftin = j;
            uut->eval();
            assert(uut->out == (j << i));
            if (i != 0) {
                assert(uut->carryout == extractBit(j, 32-i));
            }
            main_time++;
        }
    }

    // test LSR
    uut->shiftcode = 0b01;
    for (int i = 0; i < 32; ++i) {
        uut->shiftby = i;
        for (int j = -LIMIT; j < LIMIT; ++j) {
            uut->shiftin = j;
            uut->eval();
            //printf("%d, %d, %d\n", uut->out, j, i);
            assert(uut->out == (i == 0 ? 0 : lsr(j, i)));
            assert(uut->carryout == (i == 0 ? extractBit(j, 31) : extractBit(j, i-1)));
            main_time++;
        }
    }

    // test ASR
    uut->shiftcode = 0b10;
    for (int i = 0; i < 32; ++i) {
        uut->shiftby = i;
        for (int j = -LIMIT; j < LIMIT; ++j) {
            uut->shiftin = j;
            uut->eval();
            assert((uut->out) 
                == (i == 0 
                    ? (extractBit(j, 31) ? 0xFFFFFFFF : 0)
                    : j >> i)
            );
            assert(uut->carryout == (i == 0 ? extractBit(j, 31) : extractBit(j, i-1)));
            main_time++;
        }
    }

    // test ROR
    uut->shiftcode = 0b11;
    for (int i = 0; i < 32; ++i) {
        uut->shiftby = i;
        for (int j = -LIMIT; j < LIMIT; ++j) {
            uut->shiftin = j;
            uut->eval();
            if (i != 0) {
                assert(uut->out == (ror(j, i)));
                assert(uut->carryout == extractBit(uut->out, 31));
            }
            main_time++;
        }
    }

    // test RRX
    uut->shiftcode = 0b11;
    uut->shiftby = 0;
    for (int j = -LIMIT; j < LIMIT; ++j) {
        uut->shiftin = j;
        for (int k = 0; k < 2; ++k) {
            uut->cflag = k;
            uut->eval();
            //printf("%d, %d, %d, %d, %d\n", uut->out, j, i, k, (k << 31) | lsr(j, 1));
            assert(uut->out == ( (k << 31) | lsr(j, 1) ));
            assert(uut->carryout == extractBit(j, 0));
            main_time++;
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

