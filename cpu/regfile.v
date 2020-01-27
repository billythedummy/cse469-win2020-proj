module regfile
    #(parameter WORD=4,
        parameter WIDTH=8,
        parameter ADDR_WIDTH=4) 
    (in1, in2,
    we, wd, wa,
    out1, out2,
    ib, bv, iout,
    clk); 
    // input1, input2
    // write-enable, write-data (register write back), write-address
    // output1, output2,
    // isBranch, branchValue, instruction out
    // clock

    // might need a b line for ldrb

    input [ADDR_WIDTH-1:0] in1, in2;

    input we;
    input [WORD*WIDTH-1:0] wd;
    input [ADDR_WIDTH-1:0] wa;

    output reg [WORD*WIDTH-1:0] out1, out2, iout;

    input ib;
    input [WORD*WIDTH-1:0] bv;

    input clk;

    reg [(1 << ADDR_WIDTH)*WORD*WIDTH - 1:0] mem;
    // 4 * 16 bytes

    always @(posedge clk) begin
        // r15 program counter increment
        if (ib) begin
            mem[((1<<ADDR_WIDTH) - 1) * WORD*WIDTH +: WORD*WIDTH] <= mem[((1<<ADDR_WIDTH) - 1) * WORD*WIDTH +: WORD*WIDTH] + bv;
        end
        else begin
            mem[((1<<ADDR_WIDTH) - 1) * WORD*WIDTH +: WORD*WIDTH] <= mem[((1<<ADDR_WIDTH) - 1) * WORD*WIDTH +: WORD*WIDTH] + 4;
        end

        // write
        if (we) begin
            mem[ wa*WORD*WIDTH +: WORD*WIDTH ] <= wd;
        end
        // out
        out2 <= mem[in2*WORD*WIDTH +: WORD*WIDTH];
        out1 <= mem[in1*WORD*WIDTH +: WORD*WIDTH];
        iout <= mem[((1<<ADDR_WIDTH) - 1) * WORD*WIDTH +: WORD*WIDTH];
    end
endmodule