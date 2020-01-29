#include <verilated.h>          // Defines common routines
#include "Vcpu.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

#define TEST_SEL_BITS 3
#define TEST_WIDTH 8

Vcpu *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
    // what SystemC does
}

void fullClock(Vcpu* uut, VerilatedVcdC* tfp, vluint64_t* main_time) {
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
    uut = new Vcpu;   // Create instance

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
    // verilator smart enough to index by size specified
    // INSTRUCTIONS
    // bug? first instruction always there for 2 clock cycles so leave it blank for now 
    /*
    uut->cpu__DOT__instr_mem__DOT__mem[4] = 0xea;// B 8, which is actually B 16
    uut->cpu__DOT__instr_mem__DOT__mem[5] = 0x00;
    uut->cpu__DOT__instr_mem__DOT__mem[6] = 0x00;
    uut->cpu__DOT__instr_mem__DOT__mem[7] = 0x02;

    uut->cpu__DOT__instr_mem__DOT__mem[20] = 0xe1; // mov r2, r1.
    uut->cpu__DOT__instr_mem__DOT__mem[21] = 0xa0; 
    uut->cpu__DOT__instr_mem__DOT__mem[22] = 0x20; 
    uut->cpu__DOT__instr_mem__DOT__mem[23] = 0x01; 

    uut->cpu__DOT__instr_mem__DOT__mem[24] = 0xe5; // ldr r4, [r3].
    uut->cpu__DOT__instr_mem__DOT__mem[25] = 0x93;
    uut->cpu__DOT__instr_mem__DOT__mem[26] = 0x40;
    uut->cpu__DOT__instr_mem__DOT__mem[27] = 0x00;

    uut-> cpu__DOT__instr_mem__DOT__mem[28] = 0xda; // BLE -(8 + 28)+4 back to 0x04
    uut-> cpu__DOT__instr_mem__DOT__mem[29] = 0xff;
    uut-> cpu__DOT__instr_mem__DOT__mem[30] = 0xff;
    uut-> cpu__DOT__instr_mem__DOT__mem[31] = 0xf8;

    // DATA
    uut->cpu__DOT__registers__DOT__mem[8] = 0xde; // Put DEADBEEF in r2
    uut->cpu__DOT__registers__DOT__mem[9] = 0xad;
    uut->cpu__DOT__registers__DOT__mem[10] = 0xbe;
    uut->cpu__DOT__registers__DOT__mem[11] = 0xef;

    uut->cpu__DOT__registers__DOT__mem[12] = 0xca; // Put CAFEF00D in r3
    uut->cpu__DOT__registers__DOT__mem[13] = 0xfe;
    uut->cpu__DOT__registers__DOT__mem[14] = 0xf0;
    uut->cpu__DOT__registers__DOT__mem[15] = 0x0d;*

    uut->cpu__DOT__cpsr__DOT__register[0] = 0x10; // set CPSR to N != V (N=0, V=1) so ble will trigger
    uut->cpu__DOT__cpsr__DOT__register[1] = 0x00;
    uut->cpu__DOT__cpsr__DOT__register[2] = 0x00;
    uut->cpu__DOT__cpsr__DOT__register[3] = 0x00;*/

    // off we go
    uut->clk = 0;
    for (int i = 0; i < 16; ++i) {
        fullClock(uut, tfp, &main_time);
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

