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
    // write-enable, write-data (register write back), write-address, write enable
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

    reg [WORD*(1 << ADDR_WIDTH) - 1:0][WIDTH-1:0] mem;
    // 4 * 16 bytes

    always_ff @(posedge clk) begin
        // r15 program counter increment
        if (ib) begin
            mem[((1<<ADDR_WIDTH) - 1) * WORD +: WORD] <= mem[((1<<ADDR_WIDTH) - 1) * WORD +: WORD] + bv;
        end
        else begin
            mem[((1<<ADDR_WIDTH) - 1) * WORD +: WORD] <= mem[((1<<ADDR_WIDTH) - 1) * WORD +: WORD] + 4;
        end

        // write
        if (we) begin
            mem[ WORD*wa +: WORD ] <= wd;
        end
        // out
        out2 <= mem[WORD*in2 +: WORD];
        out1 <= mem[WORD*in1 +: WORD];
        iout <= mem[((1<<ADDR_WIDTH) - 1) * WORD +: WORD];
    end
endmodule