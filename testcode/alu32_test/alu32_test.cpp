#include <verilated.h>          // Defines common routines
#include "Valu32.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <limits.h>

#define V_i 0
#define C_i 1
#define Z_i 2
#define N_i 3

#define AND 0b0000 
#define EOR 0b0001 
#define SUB 0b0010
#define RSB 0b0011  
#define ADD 0b0100
#define ADC 0b0101 // ADD but add +1 if C flag is set, unsupported for now
#define SBC 0b0110 // SUB but another -1 if C flag NOT set, unsupported for now
#define RSC 0b0111 // shifter - Rn instead of Rn - shifter and another -1 f C flag, unsupported for now
#define TST 0b1000 // just AND
#define TEQ 0b1001// just EOR
#define CMP 0b1010 // just SUB
#define CMN 0b1011 // just ADD
#define ORR 0b1100 
#define PASS 0b1101 // passes shifter operand. Use this for MOV, etc
#define BIC 0b1110 // Rd = Rn AND NOT(shifter)
#define MVN 0b1111 // Rd = NOT shifter

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
    
    // basic
    int shiftercarryout = 1;
    uut->shiftercarryout = shiftercarryout;
    for (int i = 0; i < 16; ++i) {
        uut->codein = i;
        for (int j = -32; j < 32; ++j) {
            uut->Rn = j;
            for (int k = -32; k < 32; ++k) {
                main_time++;
                uut->shifter = k;
                uut->eval();
                unsigned char z = ((uut->flagsout) & (1<<Z_i)) >> Z_i;
                unsigned char c = ((uut->flagsout) & (1<<C_i)) >> C_i;
                unsigned char n = ((uut->flagsout) & (1<<N_i)) >> N_i;
                unsigned char v = ((uut->flagsout) & (1<<V_i)) >> V_i;
                switch (i) {
                    case AND:
                        assert(uut->out == (j & k));
                        assert(c == shiftercarryout);
                        break;
                    case EOR:
                        assert(uut->out == (j ^ k));
                        assert(c == shiftercarryout);
                        break;
                    case SUB:
                        assert(uut->out == (j - k));
                        assert(c == ((unsigned)j >= (unsigned)k));
                        break;
                    case RSB:
                        assert(uut->out == (k - j));
                        assert(c == ((unsigned)k >= (unsigned)j));
                        break;
                    case ADD:
                        assert(uut->out == (j + k));
                        printf("%d, %d\n", j, k);
                        assert(c == ((unsigned)(j+k) < (unsigned)j));
                        break;
                    case TST:
                        assert(uut->out == (j & k));
                        assert(c == shiftercarryout);
                        break;
                    case TEQ:
                        assert(uut->out == (j ^ k));
                        assert(c == shiftercarryout);
                        break;
                    case CMP:
                        assert(uut->out == (j - k));
                        assert(c == ((unsigned)j >= (unsigned)k));
                        break;
                    case CMN:
                        assert(uut->out == (j + k));
                        assert(c == ((unsigned)(j+k) < (unsigned)j));
                        break;
                    case PASS:
                        assert(uut->out == k);
                        assert(c == 0);
                        break;
                    case BIC:
                        assert(uut->out == (j & ~k));
                        assert(c == shiftercarryout);
                        break;
                    case MVN:
                        assert(uut->out == ~k);
                        assert(c == shiftercarryout);
                        break;
                    default: break;
                }
                assert(z == (uut->out == 0));
                assert(n == ( ((signed)uut->out) < 0));
                assert(v == 0);
            }
        }
    }

    // overflow
    unsigned char v;

    main_time++;
    uut->codein = ADD;
    uut->Rn = INT_MAX;
    uut->shifter = 1;
    uut->eval();
    v = ((uut->flagsout) & (1<<V_i)) >> V_i;
    assert(v == 1);

    main_time++;
    uut->codein = SUB;
    uut->Rn = INT_MIN;
    uut->shifter = 1;
    uut->eval();
    v = ((uut->flagsout) & (1<<V_i)) >> V_i;
    assert(v == 1);

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

