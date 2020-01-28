module reg32
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

    // default last addr (r15 in this case) is PC

    input [3:0] in1, in2, wa;
    input we, ib, clk;
    input [31:0] wd, bv;

    output reg [31:0] out1, out2, iout;

    reg [15*32 - 1:0] mem; // not including pc (own module)
    wire ispc; // is write for program counter
    assign ispc = we & (wa == 15);
    pc32 pc (.ib(ib), .bv(bv), .we(ispc), .wd(wd), .iout(iout), .clk(clk));

    always @(posedge clk) begin
        // write
        if (we & !ispc) begin
            mem[ wa*32 +: 32 ] <= wd;
        end
        // out
        out2 <= mem[in2*32 +: 32];
        out1 <= mem[in1*32 +: 32];
    end
endmodule