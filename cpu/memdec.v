`include "defines.v"

// comb decoder for mem stage
module memdec 
    (optype, is_load,
    mem_we_out, should_bypass_mem_out);

    input [`OP_TYPE_W-1 : 0] optype;
    input is_load;
    output mem_we_out, should_bypass_mem_out;

    assign mem_we_out = (optype[2:1] == `OP_LDSTR) & (~is_load); // L = 0 means store
    assign should_bypass_mem_out = ~(optype[2:1] == `OP_LDSTR);
endmodule